import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/state/answers.dart';
import 'package:trip_ai/widgets/q_option_card.dart';
import 'package:trip_ai/widgets/q_scaffold.dart';

class Q4ChillSettingScreen extends StatelessWidget {
  const Q4ChillSettingScreen({super.key});

  static const _options = <_ChillOption>[
    _ChillOption('rooftop', 'Rooftop',
        'Skyline views, breeze, evening vibes',
        Icons.deck_outlined),
    _ChillOption('garden', 'Garden',
        'Greenery, outdoor seating, slower pace',
        Icons.local_florist_outlined),
    _ChillOption('cafe', 'Cafe',
        'Indoor cosy, coffee, conversations',
        Icons.coffee_outlined),
    _ChillOption('park', 'Park',
        'Public space, benches, walks',
        Icons.park_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final answers = context.watch<AnswersState>();
    return QScaffold(
      questionNumber: 'Question 4',
      title: 'Where are we chilling?',
      subtitle: 'Pick the kind of spot.',
      child: Column(
        children: _options.map((opt) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: QOptionCard(
              label: opt.label,
              tagline: opt.tagline,
              icon: opt.icon,
              selected: answers.chillSetting == opt.key,
              onTap: () {
                answers.update(() => answers.chillSetting = opt.key);
                Navigator.of(context).pushNamed('/q5-time-of-day');
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChillOption {
  final String key;
  final String label;
  final String tagline;
  final IconData icon;
  const _ChillOption(this.key, this.label, this.tagline, this.icon);
}
