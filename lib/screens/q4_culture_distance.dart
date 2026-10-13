import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/state/answers.dart';
import 'package:trip_ai/widgets/q_option_card.dart';
import 'package:trip_ai/widgets/q_scaffold.dart';

class Q4CultureDistanceScreen extends StatelessWidget {
  const Q4CultureDistanceScreen({super.key});

  static const _options = <_DistanceOption>[
    _DistanceOption('in_amman', 'In Amman',
        'Citadel, museums, downtown — close by',
        Icons.location_city_outlined),
    _DistanceOption('outside_amman', 'Outside Amman',
        'Jerash, Petra, Ajloun — day trip',
        Icons.directions_car_outlined),
    _DistanceOption('either', 'Either',
        "Show me whatever's best",
        Icons.shuffle_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final answers = context.watch<AnswersState>();
    return QScaffold(
      questionNumber: 'Question 4',
      title: 'How far are we willing to go?',
      subtitle: 'Some of the best culture sites are outside Amman.',
      child: Column(
        children: _options.map((opt) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: QOptionCard(
              label: opt.label,
              tagline: opt.tagline,
              icon: opt.icon,
              selected: answers.cultureDriveDistance == opt.key,
              onTap: () {
                answers.update(() => answers.cultureDriveDistance = opt.key);
                Navigator.of(context).pushNamed('/q5-culture-site-type');
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DistanceOption {
  final String key;
  final String label;
  final String tagline;
  final IconData icon;
  const _DistanceOption(this.key, this.label, this.tagline, this.icon);
}
