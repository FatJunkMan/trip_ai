import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/state/answers.dart';

/// Q1: Budget tier selection.
///
/// Five vertically-stacked cards. Tapping one saves the choice to
/// AnswersState and advances to /q2-group.
///
/// The labels are hardcoded here (single source for display). The backend
/// has the same definitions in app/budget.py — keep them in sync.
class Q1BudgetScreen extends StatelessWidget {
  const Q1BudgetScreen({super.key});

  // Mirrors backend BUDGET_TIERS exactly. If you edit one, edit the other.
  static const _tiers = <_TierOption>[
    _TierOption(0, 'Free', 'Free or under 2 JD',
        'Public parks, free museums, walks'),
    _TierOption(1, 'Cheap', '2-10 JD/person',
        'Cafes, casual eats, entry-fee sites'),
    _TierOption(2, 'Mid', '10-25 JD/person',
        'Restaurants, activities, mid-range venues'),
    _TierOption(3, 'Pricey', '25-50 JD/person',
        'Nice dinners, day tours, premium spots'),
    _TierOption(4, 'Luxury', '50+ JD/person',
        'Top-end experiences, resorts, fine dining'),
  ];

  @override
  Widget build(BuildContext context) {
    final answers = context.watch<AnswersState>();
    final selected = answers.budgetTier;

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
              // Progress indicator
              const Text(
                'Question 1',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "What's your budget?",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Per person, for the whole hangout.',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: _tiers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final t = _tiers[i];
                    final isSelected = selected == t.tier;
                    return _TierCard(
                      tier: t,
                      selected: isSelected,
                      onTap: () => _select(context, t.tier),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _select(BuildContext context, int tier) {
    final answers = context.read<AnswersState>();
    answers.update(() => answers.budgetTier = tier);
    // Advance. /q2-group is added in slice 2; until then this throws,
    // which is the right behaviour during slice 1 testing.
    Navigator.of(context).pushNamed('/q2-group');
  }
}

class _TierOption {
  final int tier;
  final String label;
  final String range;
  final String description;
  const _TierOption(this.tier, this.label, this.range, this.description);
}

class _TierCard extends StatelessWidget {
  final _TierOption tier;
  final bool selected;
  final VoidCallback onTap;
  const _TierCard({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFEFFF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF534AB7)
                : const Color(0xFFE3E3DC),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tier-level dots
            _DotIndicator(filled: tier.tier + 1, total: 5),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tier.label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        tier.range,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tier.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Color(0xFF534AB7), size: 22)
            else
              const Icon(Icons.chevron_right, color: Colors.black26, size: 22),
          ],
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int filled;
  final int total;
  const _DotIndicator({required this.filled, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isOn = i < filled;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(vertical: 1.5),
          decoration: BoxDecoration(
            color: isOn ? const Color(0xFF534AB7) : const Color(0xFFE3E3DC),
            shape: BoxShape.circle,
          ),
        );
      }).reversed.toList(),
    );
  }
}
