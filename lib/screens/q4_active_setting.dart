import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/state/answers.dart';
import 'package:trip_ai/widgets/q_option_card.dart';
import 'package:trip_ai/widgets/q_scaffold.dart';

class Q4ActiveSettingScreen extends StatelessWidget {
  const Q4ActiveSettingScreen({super.key});

  static const _options = <_SettingOption>[
    _SettingOption('indoor', 'Indoor',
        'Bowling, escape rooms, climbing — weather-proof',
        Icons.sports_esports_outlined),
    _SettingOption('outdoor', 'Outdoor',
        'Hike, BBQ, parks, bike trails',
        Icons.terrain_outlined),
    _SettingOption('either', 'Either',
        "Show me whatever's best",
        Icons.shuffle_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final answers = context.watch<AnswersState>();
    return QScaffold(
      questionNumber: 'Question 4',
      title: 'Inside or outside?',
      subtitle: 'Outdoor BBQs, hiking, or indoor activities?',
      child: Column(
        children: _options.map((opt) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: QOptionCard(
              label: opt.label,
              tagline: opt.tagline,
              icon: opt.icon,
              selected: answers.activeIndoorOutdoor == opt.key,
              onTap: () {
                answers.update(() => answers.activeIndoorOutdoor = opt.key);
                Navigator.of(context).pushNamed('/q5-active-type');
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SettingOption {
  final String key;
  final String label;
  final String tagline;
  final IconData icon;
  const _SettingOption(this.key, this.label, this.tagline, this.icon);
}
