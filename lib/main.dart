import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/screens/TripSetup.dart';
import 'package:trip_ai/screens/ai_results.dart';
import 'package:trip_ai/screens/asisstant.dart';
import 'package:trip_ai/screens/trip_details.dart';
import 'package:trip_ai/screens/trip_history.dart';
import 'package:trip_ai/screens/welcome.dart';
import 'package:trip_ai/screens/home.dart';
import 'package:trip_ai/screens/q1_budget.dart';
import 'package:trip_ai/screens/q2_group.dart';
import 'package:trip_ai/screens/q3_main_thing.dart';
import 'package:trip_ai/screens/q4_food_vibe.dart';
import 'package:trip_ai/screens/q4_active_setting.dart';
import 'package:trip_ai/screens/q4_culture_distance.dart';
import 'package:trip_ai/screens/q4_chill_setting.dart';
import 'package:trip_ai/screens/q5_time_of_day.dart';
import 'package:trip_ai/screens/q5_active_type.dart';
import 'package:trip_ai/screens/q5_culture_site_type.dart';
import 'package:trip_ai/screens/q6_culture_pair.dart';
import 'package:trip_ai/screens/result.dart';
import 'package:trip_ai/screens/alternatives.dart';
import 'package:trip_ai/state/answers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnswersState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/home': (context) => const HomeScreen(),
          '/q1-budget': (context) => const Q1BudgetScreen(),
          '/q2-group': (context) => const Q2GroupScreen(),
          '/q3-main-thing': (context) => const Q3MainThingScreen(),
          '/q4-food-vibe': (context) => const Q4FoodVibeScreen(),
          '/q4-active-setting': (context) => const Q4ActiveSettingScreen(),
          '/q4-culture-distance': (context) => const Q4CultureDistanceScreen(),
          '/q4-chill-setting': (context) => const Q4ChillSettingScreen(),
          '/q5-time-of-day': (context) => const TimeOfDayScreen(),
          '/q5-active-type': (context) => const Q5ActiveTypeScreen(),
          '/q5-culture-site-type': (context) => const Q5CultureSiteTypeScreen(),
          '/q6-culture-pair': (context) => const Q6CulturePairScreen(),
          '/result': (context) => const ResultScreen(),
          '/alternatives': (context) => const AlternativesScreen(),
          // Old routes kept for compilation; not used in the new flow.
          '/setup': (context) => TripSetupScreen(),
          '/ai-results': (context) => AIResultsScreen(),
          '/trip-details': (context) => TripDetailsScreen(),
          '/history': (context) => TripHistoryScreen(),
          '/assistant': (context) => AssistantScreen(),
        },
      ),
    );
  }
}
