import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/state/answers.dart';
import 'package:trip_ai/widgets/q_option_card.dart';
import 'package:trip_ai/widgets/q_scaffold.dart';

/// Q5 for the Active branch: pick the activity type.
///
/// Options shown depend on Q4 (indoor/outdoor/either):
///   outdoor or either: hike, bbq, sports, water, adventure
///   indoor: sports, adventure
///
/// On tap: saves activeType and navigates to /q5-time-of-day (which the screen
/// labels as "Question 6" because mainThing=active).
class Q5ActiveTypeScreen extends StatelessWidget {
  const Q5ActiveTypeScreen({super.key});

  static const _allOptions = <_TypeOption>[
    _TypeOption('hike', 'Hike',
        'Trails, nature walks, scenic paths',
        Icons.hiking_outlined, _Setting.outdoor),
    _TypeOption('bbq', 'BBQ',
        'Park grills, picnic with friends',
        Icons.outdoor_grill_outlined, _Setting.outdoor),
    _TypeOption('sports', 'Sports',
        'Bowling, climbing, sports complex',
        Icons.sports_basketball_outlined, _Setting.both),
    _TypeOption('water', 'Water',
        'Swimming, paddleboarding, beach',
        Icons.pool_outlined, _Setting.outdoor),
    _TypeOption('adventure', 'Adventure',
        'Escape rooms, ziplines, cabins',
        Icons.explore_outlined, _Setting.both),
  ];

  @override
  Widget build(BuildContext context) {
    final answers = context.watch<AnswersState>();

    // Filter by Q4's indoor/outdoor choice.
    Iterable<_TypeOption> visible = _allOptions;
    if (answers.activeIndoorOutdoor == 'indoor') {
      visible = _allOptions.where((o) => o.setting == _Setting.both);
    } else if (answers.activeIndoorOutdoor == 'outdoor') {
      visible = _allOptions; // all options work outdoors (sports has both)
    }
    // 'either' or null → show all

    return QScaffold(
      questionNumber: 'Question 5',
      title: 'What kind of activity?',
      subtitle: 'Pick what sounds fun.',
      child: Column(
        children: visible.map((opt) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: QOptionCard(
              label: opt.label,
              tagline: opt.tagline,
              icon: opt.icon,
              selected: answers.activeType == opt.key,
              onTap: () {
                answers.update(() => answers.activeType = opt.key);
                // For Active, time-of-day is Q6 — same screen, smart label.
                Navigator.of(context).pushNamed('/q5-time-of-day');
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

enum _Setting { outdoor, indoor, both }

class _TypeOption {
  final String key;
  final String label;
  final String tagline;
  final IconData icon;
  final _Setting setting;
  const _TypeOption(
      this.key, this.label, this.tagline, this.icon, this.setting);
}
