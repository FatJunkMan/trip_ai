import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/state/answers.dart';
import 'package:trip_ai/widgets/q_option_card.dart';
import 'package:trip_ai/widgets/q_scaffold.dart';

class Q5CultureSiteTypeScreen extends StatelessWidget {
  const Q5CultureSiteTypeScreen({super.key});

  static const _options = <_SiteOption>[
    _SiteOption('archaeological', 'Archaeological',
        'Petra, Jerash, ancient ruins',
        Icons.foundation_outlined),
    _SiteOption('museum', 'Museum',
        'Jordan Museum, art galleries, exhibits',
        Icons.museum_outlined),
    _SiteOption('religious', 'Religious',
        'Mosques, churches, baptism site',
        Icons.brightness_5_outlined),
    _SiteOption('castle', 'Castle',
        'Ajloun, Karak, Shobak, desert castles',
        Icons.fort_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final answers = context.watch<AnswersState>();
    return QScaffold(
      questionNumber: 'Question 5',
      title: 'What kind of site?',
      subtitle: "Jordan has more of each than most countries.",
      child: Column(
        children: _options.map((opt) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: QOptionCard(
              label: opt.label,
              tagline: opt.tagline,
              icon: opt.icon,
              selected: answers.cultureSiteType == opt.key,
              onTap: () {
                answers.update(() => answers.cultureSiteType = opt.key);
                Navigator.of(context).pushNamed('/q6-culture-pair');
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SiteOption {
  final String key;
  final String label;
  final String tagline;
  final IconData icon;
  const _SiteOption(this.key, this.label, this.tagline, this.icon);
}
