import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/services/api.dart';
import 'package:trip_ai/state/answers.dart';

/// Submit the current answers to /plan and navigate to /result.
///
/// Used by Q5/Q6 final-question screens. The screen sets its own loading
/// state (via the LoadingButton widget); this function just handles the
/// async call and navigation.
///
/// On success, navigates to /result with the PlanResult as arguments.
/// On error, shows a snackbar and stays on the current screen.
///
/// Returns true if navigation happened, false if there was an error.
Future<bool> submitAndNavigate(BuildContext context) async {
  final answers = context.read<AnswersState>();
  final payload = answers.toRequestPayload();

  try {
    final result = await api.plan(payload);
    // ignore: use_build_context_synchronously
    if (!context.mounted) return false;
    Navigator.of(context).pushNamed('/result', arguments: result);
    return true;
  } on ApiException catch (e) {
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Couldn\'t reach the server: ${e.message}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return false;
  } catch (e) {
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Something went wrong: $e'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return false;
  }
}
