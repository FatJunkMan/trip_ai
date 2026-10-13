import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/models/models.dart';
import 'package:trip_ai/services/api.dart';
import 'package:trip_ai/state/answers.dart';

/// Home screen — spartan version.
///
/// Two things only:
///   - "Plan Your Trip" button -> /q1-budget
///   - Saved trips list (from GET /trips), tap to revisit a result
///
/// Re-fetches trips every time the screen becomes visible so that newly
/// saved plans show up immediately when the user navigates back.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  List<SavedTripModel>? _trips;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final trips = await api.listTrips();
      if (!mounted) return;
      setState(() {
        _trips = trips;
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

  Future<void> _delete(String tripId) async {
    try {
      await api.deleteTrip(tripId);
      await _fetch();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trip deleted"),
            behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't delete: $e")),
      );
    }
  }

  void _openTrip(SavedTripModel trip) {
    // Restore the answers into AnswersState so 'Show alternatives' from the
    // restored result still has the right context.
    final answers = context.read<AnswersState>();
    answers.update(() {
      answers.budgetTier = trip.answers['budget_tier'] as int?;
      answers.groupSize = trip.answers['group_size'] as int?;
      answers.audience = trip.answers['audience'] as String?;
      answers.wheelchairUser = (trip.answers['wheelchair_user'] as bool?) ?? false;
      answers.mainThing = trip.answers['main_thing'] as String?;
      answers.timeOfDay = trip.answers['time_of_day'] as String?;
      // Branch-specific
      final bs = (trip.answers['branch_specific'] as Map?)?.cast<String, dynamic>()
          ?? const {};
      answers.foodVibe = bs['vibe'] as String?;
      answers.activeIndoorOutdoor = bs['indoor_outdoor'] as String?;
      answers.activeType = bs['active_type'] as String?;
      answers.cultureDriveDistance = bs['drive_distance'] as String?;
      answers.cultureSiteType = bs['site_type'] as String?;
      answers.culturePairWithFood = bs['pair_with_food'] as bool?;
      answers.chillSetting = bs['setting'] as String?;
    });

    // Wrap the saved venue back into a PlanOk and navigate.
    final synthetic = PlanOk(
      venue: trip.venue,
      // We didn't save the match summary; reconstruct a plain one.
      matchSummary: MatchSummary(
        whyThisOne: 'Saved on ${_shortDate(trip.savedAt)}',
        matchedTags: const [],
        rankScore: 0,
      ),
      alcoholAlternatives: AlcoholAlternativesInfo(
        available: trip.venue.servesAlcohol,
        shown: false,
      ),
    );
    Navigator.of(context).pushNamed('/result', arguments: synthetic)
        .then((_) => _fetch());
  }

  String _shortDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simple title — no gradient, no oversized hero.
              const Text(
                'Hangout Planner',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Find a spot to hang. Friday-ready.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 32),

              // The single primary action.
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Reset answers so a fresh plan starts cleanly.
                    context.read<AnswersState>().reset();
                    Navigator.of(context).pushNamed('/q1-budget')
                        .then((_) => _fetch());
                  },
                  icon: const Icon(Icons.explore_outlined, size: 20),
                  label: const Text(
                    'Plan a hangout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF534AB7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Saved trips section header
              const Text(
                'YOUR SAVED PLANS',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
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
                size: 40, color: Colors.black38),
            const SizedBox(height: 8),
            Text(
              "Couldn't reach server",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _fetch, child: const Text('Retry')),
          ],
        ),
      );
    }
    final trips = _trips ?? const [];
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border, size: 48, color: Colors.black26),
            const SizedBox(height: 12),
            const Text(
              "No saved plans yet",
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            const Text(
              "Plan one and tap Save to bookmark it.",
              style: TextStyle(fontSize: 13, color: Colors.black38),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetch,
      color: const Color(0xFF534AB7),
      child: ListView.separated(
        itemCount: trips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _SavedTripCard(
          trip: trips[i],
          onTap: () => _openTrip(trips[i]),
          onDelete: () => _confirmDelete(trips[i]),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(SavedTripModel trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete saved plan?'),
        content: Text('"${trip.title}" will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) await _delete(trip.id);
  }
}

class _SavedTripCard extends StatelessWidget {
  final SavedTripModel trip;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _SavedTripCard({
    required this.trip,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
            // Mini venue indicator: gradient square with first letter
            Container(
              width: 44, height: 44,
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
                  trip.venue.nameEn.isEmpty
                      ? '?'
                      : trip.venue.nameEn[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
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
                  Text(
                    trip.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trip.venue.nameEn,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(trip.savedAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.black38),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
