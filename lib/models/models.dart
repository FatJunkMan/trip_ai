/// Data model classes for /plan and /alternatives responses.
///
/// Hand-written (no codegen) because the schemas are stable and small.
/// Each class has a fromJson factory that copes with missing/null fields.
library;

class Coords {
  final double lat;
  final double lng;
  const Coords({required this.lat, required this.lng});
  factory Coords.fromJson(Map<String, dynamic> j) => Coords(
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
      );
}

class HoursToday {
  final String opens;
  final String closes;
  const HoursToday({required this.opens, required this.closes});
  factory HoursToday.fromJson(Map<String, dynamic> j) => HoursToday(
        opens: j['opens'] as String,
        closes: j['closes'] as String,
      );
}

class VenueCardModel {
  final String venueId;
  final String nameEn;
  final String nameAr;
  final String venueType;
  final String governorate;
  final String neighborhood;
  final Coords coords;
  final int priceTier;
  final String? priceNoteJd;
  final List<String> activityTags;
  final List<String> vibeTags;
  final List<String> audienceFit;
  final bool servesAlcohol;
  final bool hasView;
  final String wheelchairAccessible; // 'Y' | 'N' | 'unknown'
  final List<String> constraints;
  final String? parking;
  final HoursToday? hoursToday;
  final String? reservationPhone;
  final double? googleRating;
  final int? googleRatingCount;
  final String? curatorNote;
  final String? photoUrl;
  final String googleMapsUrl;
  final bool verifiedByAj;

  const VenueCardModel({
    required this.venueId,
    required this.nameEn,
    required this.nameAr,
    required this.venueType,
    required this.governorate,
    required this.neighborhood,
    required this.coords,
    required this.priceTier,
    required this.priceNoteJd,
    required this.activityTags,
    required this.vibeTags,
    required this.audienceFit,
    required this.servesAlcohol,
    required this.hasView,
    required this.wheelchairAccessible,
    required this.constraints,
    required this.parking,
    required this.hoursToday,
    required this.reservationPhone,
    required this.googleRating,
    required this.googleRatingCount,
    required this.curatorNote,
    required this.photoUrl,
    required this.googleMapsUrl,
    required this.verifiedByAj,
  });

  factory VenueCardModel.fromJson(Map<String, dynamic> j) {
    List<String> _strs(dynamic raw) =>
        (raw as List?)?.cast<String>() ?? const [];
    return VenueCardModel(
      venueId: j['venue_id'] as String,
      nameEn: j['name_en'] as String,
      nameAr: j['name_ar'] as String,
      venueType: j['venue_type'] as String,
      governorate: j['governorate'] as String,
      neighborhood: j['neighborhood'] as String,
      coords: Coords.fromJson(j['coords'] as Map<String, dynamic>),
      priceTier: j['price_tier'] as int,
      priceNoteJd: j['price_note_jd'] as String?,
      activityTags: _strs(j['activity_tags']),
      vibeTags: _strs(j['vibe_tags']),
      audienceFit: _strs(j['audience_fit']),
      servesAlcohol: j['serves_alcohol'] as bool,
      hasView: j['has_view'] as bool,
      wheelchairAccessible: j['wheelchair_accessible'] as String,
      constraints: _strs(j['constraints']),
      parking: j['parking'] as String?,
      hoursToday: j['hours_today'] == null
          ? null
          : HoursToday.fromJson(j['hours_today'] as Map<String, dynamic>),
      reservationPhone: j['reservation_phone'] as String?,
      googleRating: (j['google_rating'] as num?)?.toDouble(),
      googleRatingCount: j['google_rating_count'] as int?,
      curatorNote: j['curator_note'] as String?,
      photoUrl: j['photo_url'] as String?,
      googleMapsUrl: j['google_maps_url'] as String,
      verifiedByAj: j['verified_by_aj'] as bool,
    );
  }

  /// Round-trip back to the JSON shape — needed when re-sending to the
  /// backend (e.g. POST /trips includes the venue payload).
  Map<String, dynamic> toJson() => {
        'venue_id': venueId,
        'name_en': nameEn,
        'name_ar': nameAr,
        'venue_type': venueType,
        'governorate': governorate,
        'neighborhood': neighborhood,
        'coords': {'lat': coords.lat, 'lng': coords.lng},
        'price_tier': priceTier,
        'price_note_jd': priceNoteJd,
        'activity_tags': activityTags,
        'vibe_tags': vibeTags,
        'audience_fit': audienceFit,
        'serves_alcohol': servesAlcohol,
        'has_view': hasView,
        'wheelchair_accessible': wheelchairAccessible,
        'constraints': constraints,
        'parking': parking,
        'hours_today': hoursToday == null
            ? null
            : {'opens': hoursToday!.opens, 'closes': hoursToday!.closes},
        'reservation_phone': reservationPhone,
        'google_rating': googleRating,
        'google_rating_count': googleRatingCount,
        'curator_note': curatorNote,
        'photo_url': photoUrl,
        'google_maps_url': googleMapsUrl,
        'verified_by_aj': verifiedByAj,
      };
}

class MatchSummary {
  final String whyThisOne;
  final List<String> matchedTags;
  final double rankScore;
  const MatchSummary({
    required this.whyThisOne,
    required this.matchedTags,
    required this.rankScore,
  });
  factory MatchSummary.fromJson(Map<String, dynamic> j) => MatchSummary(
        whyThisOne: j['why_this_one'] as String,
        matchedTags: (j['matched_tags'] as List?)?.cast<String>() ?? const [],
        rankScore: (j['rank_score'] as num).toDouble(),
      );
}

class AlcoholAlternativesInfo {
  final bool available;
  final bool shown;
  const AlcoholAlternativesInfo({
    required this.available,
    required this.shown,
  });
  factory AlcoholAlternativesInfo.fromJson(Map<String, dynamic> j) =>
      AlcoholAlternativesInfo(
        available: j['available'] as bool,
        shown: j['shown'] as bool? ?? false,
      );
}

class Suggestion {
  final String tweak;
  final String labelEn;
  const Suggestion({required this.tweak, required this.labelEn});
  factory Suggestion.fromJson(Map<String, dynamic> j) => Suggestion(
        tweak: j['tweak'] as String,
        labelEn: j['label_en'] as String,
      );
}

/// Discriminated union: either Ok with a venue, or Empty with suggestions.
sealed class PlanResult {
  const PlanResult();
  factory PlanResult.fromJson(Map<String, dynamic> j) {
    final status = j['status'] as String;
    if (status == 'ok') {
      return PlanOk(
        venue: VenueCardModel.fromJson(j['venue'] as Map<String, dynamic>),
        matchSummary:
            MatchSummary.fromJson(j['match_summary'] as Map<String, dynamic>),
        alcoholAlternatives: AlcoholAlternativesInfo.fromJson(
            j['alcohol_alternatives'] as Map<String, dynamic>),
      );
    }
    if (status == 'no_matches') {
      return PlanEmpty(
        reason: j['reason'] as String,
        suggestions: ((j['suggestions'] as List?) ?? const [])
            .map((s) => Suggestion.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
    }
    throw FormatException('Unknown plan status: $status');
  }
}

class PlanOk extends PlanResult {
  final VenueCardModel venue;
  final MatchSummary matchSummary;
  final AlcoholAlternativesInfo alcoholAlternatives;
  const PlanOk({
    required this.venue,
    required this.matchSummary,
    required this.alcoholAlternatives,
  });
}

class PlanEmpty extends PlanResult {
  final String reason;
  final List<Suggestion> suggestions;
  const PlanEmpty({required this.reason, required this.suggestions});
}

/// Parallel arrays: venues[i] corresponds to matchSummaries[i].
class AlternativesResult {
  final List<VenueCardModel> venues;
  final List<MatchSummary> matchSummaries;
  const AlternativesResult({
    required this.venues,
    required this.matchSummaries,
  });
  factory AlternativesResult.fromJson(Map<String, dynamic> j) {
    final v = (j['venues'] as List? ?? const [])
        .map((e) => VenueCardModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final m = (j['match_summaries'] as List? ?? const [])
        .map((e) => MatchSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    return AlternativesResult(venues: v, matchSummaries: m);
  }
}


/// One saved trip — venue + answers + auto-generated title.
class SavedTripModel {
  final String id;
  final String title;
  final String savedAt;  // ISO timestamp string
  final Map<String, dynamic> answers;  // raw answers payload — re-runnable
  final VenueCardModel venue;
  const SavedTripModel({
    required this.id,
    required this.title,
    required this.savedAt,
    required this.answers,
    required this.venue,
  });
  factory SavedTripModel.fromJson(Map<String, dynamic> j) => SavedTripModel(
        id: j['id'] as String,
        title: j['title'] as String,
        savedAt: j['saved_at'] as String,
        answers: Map<String, dynamic>.from(j['answers'] as Map),
        venue: VenueCardModel.fromJson(j['venue'] as Map<String, dynamic>),
      );
}
