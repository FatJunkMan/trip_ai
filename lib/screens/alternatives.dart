import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/models/models.dart';
import 'package:trip_ai/state/answers.dart';
import 'package:trip_ai/services/api.dart';
import 'package:trip_ai/screens/result.dart';
import 'package:trip_ai/widgets/loading_overlay.dart';

/// Alternatives list screen.
///
/// Displays up to 5 next-best venues that match the same answers. Reused
/// for both regular alternatives and the alcohol-serving alternatives —
/// distinguished by AlternativesArgs.alcoholOnly.
///
/// Tap any card → navigate to /result with that venue as the selected one.
class AlternativesScreen extends StatefulWidget {
  const AlternativesScreen({super.key});

  @override
  State<AlternativesScreen> createState() => _AlternativesScreenState();
}

class _AlternativesScreenState extends State<AlternativesScreen> {
  AlternativesResult? _result;
  bool _loading = true;
  String? _error;
  AlternativesArgs? _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_args != null) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is AlternativesArgs) {
      _args = args;
      _fetch();
    }
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final answers = context.read<AnswersState>();
      final res = await api.alternatives(
        answersPayload: answers.toRequestPayload(),
        excludeIds: _args!.excludeIds,
        alcoholOnly: _args!.alcoholOnly,
        nonAlcoholOnly: _args!.nonAlcoholOnly,
      );
      if (!mounted) return;
      setState(() {
        _result = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _select(int index) {
    if (_result == null) return;
    final venue = _result!.venues[index];
    final summary = _result!.matchSummaries[index];
    // Build a PlanOk wrapper so the result screen can render this pick
    // without a fresh /plan call.
    final synthetic = PlanOk(
      venue: venue,
      matchSummary: summary,
      // Re-derive the alcohol-alternatives availability — for a tapped
      // alternative, we don't need to surface a button to a deeper level.
      alcoholAlternatives:
          const AlcoholAlternativesInfo(available: false, shown: true),
    );
    Navigator.of(context).pushNamed('/result', arguments: synthetic);
  }

  @override
  Widget build(BuildContext context) {
    final isAlcoholList = _args?.alcoholOnly ?? false;
    final title =
        isAlcoholList ? 'Alcohol-serving spots' : 'Other good options';
    final subtitle = isAlcoholList
        ? 'Same answers, venues that serve alcohol.'
        : 'Same answers, ranked next-best.';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              if (isAlcoholList) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF1DF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: Color(0xFFB07A2F)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Legal age (18+) applies. Drink responsibly.',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF6E5018)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(
        color: Color(0xFF534AB7),
      ));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 48, color: Colors.black38),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            TextButton(onPressed: _fetch, child: const Text('Retry')),
          ],
        ),
      );
    }
    final venues = _result?.venues ?? const [];
    if (venues.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            "No more matches. Try a different answer or come back to the "
            "first suggestion.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: venues.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _MiniVenueCard(
        venue: venues[i],
        summary: _result!.matchSummaries[i],
        onTap: () => _select(i),
      ),
    );
  }
}

class _MiniVenueCard extends StatelessWidget {
  final VenueCardModel venue;
  final MatchSummary summary;
  final VoidCallback onTap;
  const _MiniVenueCard({
    required this.venue,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priceLabel = venue.priceTier == 0
        ? 'Free'
        : (venue.priceNoteJd ?? '\$' * (venue.priceTier));
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE3E3DC), width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiny gradient square as a stand-in for a photo
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF534AB7), Color(0xFF8C84D8)],
                ),
              ),
              child: Center(
                child: Text(
                  venue.nameEn.isEmpty ? '?' : venue.nameEn[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          venue.nameEn,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (venue.verifiedByAj)
                        const Icon(Icons.verified,
                            size: 14, color: Color(0xFF3D8A6B)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_humanizeType(venue.venueType)} · ${venue.neighborhood}',
                    style: const TextStyle(
                      fontSize: 11, color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(priceLabel, style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w500,
                          color: Colors.black87)),
                      if (venue.googleRating != null) ...[
                        const SizedBox(width: 8),
                        Text('· ${venue.googleRating!.toStringAsFixed(1)} ★',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black54)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  String _humanizeType(String t) {
    return t.split('_').map((w) => w.isEmpty
        ? ''
        : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }
}
