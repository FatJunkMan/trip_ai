import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/state/answers.dart';
import 'package:trip_ai/services/submit.dart';
import 'package:trip_ai/widgets/loading_overlay.dart';
import 'package:trip_ai/widgets/q_option_card.dart';
import 'package:trip_ai/widgets/q_scaffold.dart';

/// Time of Day screen — shared by all branches.
///
/// For Food and Chill this is Q5 (their last question before submit).
/// For Active this is Q6 (after activity type).
/// The question number label adapts based on AnswersState.mainThing.
///
/// On tap: saves timeOfDay, sets loading state, calls /plan, navigates
/// to /result with the response.
class TimeOfDayScreen extends StatefulWidget {
  const TimeOfDayScreen({super.key});

  @override
  State<TimeOfDayScreen> createState() => _TimeOfDayScreenState();
}

class _TimeOfDayScreenState extends State<TimeOfDayScreen> {
  bool _loading = false;

  static const _options = <_TimeOption>[
    _TimeOption('morning', 'Morning',
        '~9 AM to noon — quieter, brighter, fewer crowds',
        Icons.wb_sunny_outlined),
    _TimeOption('afternoon', 'Afternoon',
        '~Noon to 5 PM — lunch hour, midday energy',
        Icons.light_mode_outlined),
    _TimeOption('evening', 'Evening',
        '~5 PM to 9 PM — dinner, sunset, busiest',
        Icons.nights_stay_outlined),
    _TimeOption('night', 'Night',
        '~9 PM to 1 AM — late dinner, drinks, calmer',
        Icons.bedtime_outlined),
  ];

  Future<void> _handleTap(_TimeOption opt) async {
    if (_loading) return;
    final answers = context.read<AnswersState>();
    answers.update(() => answers.timeOfDay = opt.key);
    setState(() => _loading = true);
    final ok = await submitAndNavigate(context);
    if (!mounted) return;
    setState(() => _loading = false);
    // If ok=false, snackbar already shown by submitAndNavigate
  }

  @override
  Widget build(BuildContext context) {
    final answers = context.watch<AnswersState>();
    final isActiveQ6 = answers.mainThing == 'active';
    final qNumber = isActiveQ6 ? 'Question 6' : 'Question 5';

    return Stack(
      children: [
        QScaffold(
          questionNumber: qNumber,
          title: 'When are we going?',
          subtitle: 'Affects which venues are open and how busy they are.',
          child: Column(
            children: _options.map((opt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _loading ? 0.4 : 1.0,
                  child: IgnorePointer(
                    ignoring: _loading,
                    child: QOptionCard(
                      label: opt.label,
                      tagline: opt.tagline,
                      icon: opt.icon,
                      selected: answers.timeOfDay == opt.key,
                      onTap: () => _handleTap(opt),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_loading)
          const LoadingOverlay(message: "Finding your spot..."),
      ],
    );
  }
}

class _TimeOption {
  final String key;
  final String label;
  final String tagline;
  final IconData icon;
  const _TimeOption(this.key, this.label, this.tagline, this.icon);
}
