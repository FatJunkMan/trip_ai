import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/state/answers.dart';
import 'package:trip_ai/services/submit.dart';
import 'package:trip_ai/widgets/loading_overlay.dart';
import 'package:trip_ai/widgets/q_option_card.dart';
import 'package:trip_ai/widgets/q_scaffold.dart';

/// Q6 for the Culture branch: pair the site visit with a food stop.
class Q6CulturePairScreen extends StatefulWidget {
  const Q6CulturePairScreen({super.key});

  @override
  State<Q6CulturePairScreen> createState() => _Q6CulturePairScreenState();
}

class _Q6CulturePairScreenState extends State<Q6CulturePairScreen> {
  bool _loading = false;

  Future<void> _handleTap(bool pairWithFood) async {
    if (_loading) return;
    final answers = context.read<AnswersState>();
    answers.update(() => answers.culturePairWithFood = pairWithFood);
    setState(() => _loading = true);
    await submitAndNavigate(context);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final answers = context.watch<AnswersState>();
    return Stack(
      children: [
        QScaffold(
          questionNumber: 'Question 6',
          title: 'Pair it with a meal?',
          subtitle: "We'll suggest a food spot near the site.",
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _loading ? 0.4 : 1.0,
            child: IgnorePointer(
              ignoring: _loading,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: QOptionCard(
                      label: 'Yes, suggest food too',
                      tagline:
                          'A nearby restaurant or cafe to round out the visit',
                      icon: Icons.restaurant_outlined,
                      selected: answers.culturePairWithFood == true,
                      onTap: () => _handleTap(true),
                    ),
                  ),
                  QOptionCard(
                    label: 'No, just the site',
                    tagline: "We'll plan around it ourselves",
                    icon: Icons.close_outlined,
                    selected: answers.culturePairWithFood == false,
                    onTap: () => _handleTap(false),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_loading)
          const LoadingOverlay(message: "Finding your spot..."),
      ],
    );
  }
}
