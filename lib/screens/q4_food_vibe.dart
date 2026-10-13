import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/state/answers.dart';
import 'package:trip_ai/widgets/q_option_card.dart';
import 'package:trip_ai/widgets/q_scaffold.dart';

class Q4FoodVibeScreen extends StatelessWidget {
  const Q4FoodVibeScreen({super.key});

  static const _options = <_VibeOption>[
    _VibeOption('fancy', 'Fancy',
        'White tablecloths, attentive service, dressed up',
        Icons.local_bar_outlined),
    _VibeOption('casual', 'Casual',
        'Relaxed, walk-in friendly, mid-range vibes',
        Icons.lunch_dining_outlined),
    _VibeOption('traditional', 'Traditional',
        'Authentic Jordanian — mansaf, mezze, hospitality',
        Icons.restaurant_menu_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final answers = context.watch<AnswersState>();
    return QScaffold(
      questionNumber: 'Question 4',
      title: 'What kind of food vibe?',
      subtitle: 'Pick what fits the night.',
      child: Column(
        children: _options.map((opt) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: QOptionCard(
              label: opt.label,
              tagline: opt.tagline,
              icon: opt.icon,
              selected: answers.foodVibe == opt.key,
              onTap: () {
                answers.update(() => answers.foodVibe = opt.key);
                Navigator.of(context).pushNamed('/q5-time-of-day');
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _VibeOption {
  final String key;
  final String label;
  final String tagline;
  final IconData icon;
  const _VibeOption(this.key, this.label, this.tagline, this.icon);
}
