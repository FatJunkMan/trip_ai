import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/state/answers.dart';

/// Q3: Main thing (the four-branch picker).
///
/// Tapping a card saves the choice to AnswersState.mainThing and routes
/// to the first per-branch question screen for that branch.
///
/// Routes (added in slice 4):
///   food    -> /q4-food-vibe
///   active  -> /q4-active-setting
///   culture -> /q4-culture-distance
///   chill   -> /q4-chill-setting
class Q3MainThingScreen extends StatelessWidget {
  const Q3MainThingScreen({super.key});

  static const _branches = <_Branch>[
    _Branch(
      key: 'food',
      label: 'Food',
      tagline: 'Restaurants, cafes, food halls',
      icon: Icons.restaurant_outlined,
      tint: Color(0xFFE07A5F),
      bg: Color(0xFFFCEEEA),
      route: '/q4-food-vibe',
    ),
    _Branch(
      key: 'active',
      label: 'Active',
      tagline: 'Hike, BBQ, sports, outdoor',
      icon: Icons.directions_run_outlined,
      tint: Color(0xFF3D8A6B),
      bg: Color(0xFFE7F4EE),
      route: '/q4-active-setting',
    ),
    _Branch(
      key: 'culture',
      label: 'Culture',
      tagline: 'Museums, sites, history',
      icon: Icons.account_balance_outlined,
      tint: Color(0xFFB07A2F),
      bg: Color(0xFFFAF1DF),
      route: '/q4-culture-distance',
    ),
    _Branch(
      key: 'chill',
      label: 'Chill',
      tagline: 'Cafes, rooftops, gardens',
      icon: Icons.local_cafe_outlined,
      tint: Color(0xFF7A4FA8),
      bg: Color(0xFFF1EAFA),
      route: '/q4-chill-setting',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final answers = context.watch<AnswersState>();

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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Question 3',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'What are we doing?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pick the main thing. Side activities can come later.',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                  children: _branches.map((b) {
                    return _BranchCard(
                      branch: b,
                      selected: answers.mainThing == b.key,
                      onTap: () => _select(context, b),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _select(BuildContext context, _Branch b) {
    final answers = context.read<AnswersState>();
    answers.update(() => answers.mainThing = b.key);
    Navigator.of(context).pushNamed(b.route);
  }
}

class _Branch {
  final String key;
  final String label;
  final String tagline;
  final IconData icon;
  final Color tint;
  final Color bg;
  final String route;
  const _Branch({
    required this.key,
    required this.label,
    required this.tagline,
    required this.icon,
    required this.tint,
    required this.bg,
    required this.route,
  });
}

class _BranchCard extends StatelessWidget {
  final _Branch branch;
  final bool selected;
  final VoidCallback onTap;
  const _BranchCard({
    required this.branch,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? branch.bg : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? branch.tint : const Color(0xFFE3E3DC),
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? branch.tint : branch.bg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                branch.icon,
                color: selected ? Colors.white : branch.tint,
                size: 24,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: selected ? branch.tint : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  branch.tagline,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
