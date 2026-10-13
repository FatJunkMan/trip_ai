import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trip_ai/models/models.dart';

/// Single source of truth for the backend URL.
///
/// For local dev:
/// - Android emulator: 10.0.2.2 maps to host's localhost
/// - iOS simulator: localhost
/// - Real device: use the host's LAN IP (e.g. 192.168.1.x)
///
/// To override at runtime: pass --dart-define=API_BASE=http://192.168.1.42:8000
const String _baseUrl = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://10.0.2.2:8000',
);

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final http.Client _client = http.Client();

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  /// GET /health — sanity check.
  Future<Map<String, dynamic>> health() async {
    final res = await _client.get(_uri('/health'));
    if (res.statusCode != 200) {
      throw ApiException('Health check failed', statusCode: res.statusCode);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// POST /plan — request a venue recommendation.
  ///
  /// Returns either PlanOk (with a venue) or PlanEmpty (with relaxation
  /// suggestions). Both are valid 200 responses; the discriminated union
  /// handles them.
  Future<PlanResult> plan(Map<String, dynamic> answersPayload) async {
    final res = await _client.post(
      _uri('/plan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(answersPayload),
    );
    if (res.statusCode != 200) {
      throw ApiException(
        'Plan request failed: ${res.body}',
        statusCode: res.statusCode,
      );
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return PlanResult.fromJson(json);
  }

  /// POST /alternatives — request next-best venues.
  ///
  /// [excludeIds]: venue_ids the user has already seen (typically the top
  /// pick from /plan). [alcoholOnly]: when true, only alcohol-serving venues
  /// are returned (powers the 'Show alcohol alternatives' button).
  /// [nonAlcoholOnly]: when true, explicitly excludes alcohol-serving venues
  /// (used when the current pick is non-alcohol and the user taps regular
  /// "Show alternatives" — keeps the list consistent with their preference).
  Future<AlternativesResult> alternatives({
    required Map<String, dynamic> answersPayload,
    List<String> excludeIds = const [],
    bool alcoholOnly = false,
    bool nonAlcoholOnly = false,
  }) async {
    final body = {
      ...answersPayload,
      'exclude_ids': excludeIds,
      'alcohol_only': alcoholOnly,
      'non_alcohol_only': nonAlcoholOnly,
    };
    final res = await _client.post(
      _uri('/alternatives'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw ApiException(
        'Alternatives request failed: ${res.body}',
        statusCode: res.statusCode,
      );
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return AlternativesResult.fromJson(json);
  }

  // ============================================================
  // Saved trips
  // ============================================================

  /// GET /trips — list all saved trips, newest first.
  Future<List<SavedTripModel>> listTrips() async {
    final res = await _client.get(_uri('/trips'));
    if (res.statusCode != 200) {
      throw ApiException('listTrips failed', statusCode: res.statusCode);
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final trips = (json['trips'] as List? ?? const [])
        .map((e) => SavedTripModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return trips;
  }

  /// POST /trips — save a trip. Returns the persisted entry.
  Future<SavedTripModel> saveTrip({
    required Map<String, dynamic> answers,
    required VenueCardModel venue,
  }) async {
    final body = {
      'answers': answers,
      'venue': venue.toJson(),
    };
    final res = await _client.post(
      _uri('/trips'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw ApiException(
        'saveTrip failed: ${res.body}',
        statusCode: res.statusCode,
      );
    }
    return SavedTripModel.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  /// DELETE /trips/{id}.
  Future<void> deleteTrip(String tripId) async {
    final res = await _client.delete(_uri('/trips/$tripId'));
    if (res.statusCode != 200) {
      throw ApiException(
        'deleteTrip failed: ${res.body}',
        statusCode: res.statusCode,
      );
    }
  }

  void dispose() => _client.close();
}

/// Convenience singleton — most screens use this directly.
final api = ApiClient();
