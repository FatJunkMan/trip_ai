import 'package:flutter/foundation.dart';

/// Accumulates user answers across the Q1 -> Q6 question flow.
///
/// One instance lives at the root of the app (provided in main.dart).
/// Each question screen reads the field it cares about, writes back to it,
/// then navigates to the next screen.
///
/// All fields are nullable until answered. The decision to submit lives in
/// the final per-branch screen, which checks isComplete() before sending.
class AnswersState extends ChangeNotifier {
  // ----- Universal questions -----

  /// Q1: budget tier (0=free .. 4=luxury). Null until answered.
  int? budgetTier;

  /// Q2: group size (>= 1).
  int? groupSize;

  /// Q2: audience — one of 'couples', 'families', 'singles', 'mixed'.
  String? audience;

  /// Q2: wheelchair user in group.
  bool wheelchairUser = false;

  /// Q3: main thing — one of 'food', 'active', 'culture', 'chill'.
  String? mainThing;

  // ----- Per-branch (optional, only one branch's fields populated) -----

  // Food:
  String? foodVibe; // 'fancy' | 'casual' | 'traditional'

  // Active:
  String? activeIndoorOutdoor; // 'indoor' | 'outdoor' | 'either'
  String? activeType; // e.g. 'bbq' | 'hike' | 'bowling'

  // Culture:
  String? cultureDriveDistance; // 'in_amman' | 'outside_amman' | 'either'
  String? cultureSiteType; // 'archaeological' | 'museum' | 'religious' | 'castle'
  /// Tri-state on purpose: null=unset, true=yes, false=no. The Q6 screen needs
  /// to distinguish "user hasn't answered yet" from "user picked No" so the
  /// card highlight logic works on back-navigation.
  bool? culturePairWithFood;

  // Chill:
  String? chillSetting; // 'rooftop' | 'garden' | 'cafe' | 'park'

  // ----- Time of day (per-branch, but stored once for simplicity) -----

  /// 'morning' | 'afternoon' | 'evening' | 'night'.
  String? timeOfDay;

  // -------- Helpers --------

  void reset() {
    budgetTier = null;
    groupSize = null;
    audience = null;
    wheelchairUser = false;
    mainThing = null;
    foodVibe = null;
    activeIndoorOutdoor = null;
    activeType = null;
    cultureDriveDistance = null;
    cultureSiteType = null;
    culturePairWithFood = null;
    chillSetting = null;
    timeOfDay = null;
    notifyListeners();
  }

  /// Set a value and trigger a rebuild on listening widgets.
  void update(void Function() mutate) {
    mutate();
    notifyListeners();
  }

  /// Are the universal questions complete?
  bool get hasUniversalAnswers =>
      budgetTier != null &&
      groupSize != null &&
      audience != null &&
      mainThing != null;

  /// Build the JSON payload to send to /plan.
  /// Only call once the relevant branch's fields are populated.
  Map<String, dynamic> toRequestPayload() {
    final branchSpecific = <String, dynamic>{};
    switch (mainThing) {
      case 'food':
        if (foodVibe != null) branchSpecific['vibe'] = foodVibe;
        break;
      case 'active':
        if (activeIndoorOutdoor != null) {
          branchSpecific['indoor_outdoor'] = activeIndoorOutdoor;
        }
        if (activeType != null) branchSpecific['active_type'] = activeType;
        break;
      case 'culture':
        if (cultureDriveDistance != null) {
          branchSpecific['drive_distance'] = cultureDriveDistance;
        }
        if (cultureSiteType != null) {
          branchSpecific['site_type'] = cultureSiteType;
        }
        branchSpecific['pair_with_food'] = culturePairWithFood ?? false;
        break;
      case 'chill':
        if (chillSetting != null) branchSpecific['setting'] = chillSetting;
        break;
    }
    return {
      'answers': {
        'budget_tier': budgetTier,
        'group_size': groupSize,
        'audience': audience,
        'wheelchair_user': wheelchairUser,
        'main_thing': mainThing,
        'time_of_day': timeOfDay,
        'branch_specific': branchSpecific,
      }
    };
  }

  @override
  String toString() =>
      'Answers(budget=$budgetTier, group=$groupSize/$audience/wheelchair=$wheelchairUser, main=$mainThing, branch={food:$foodVibe, active:$activeIndoorOutdoor/$activeType, culture:$cultureDriveDistance/$cultureSiteType/$culturePairWithFood, chill:$chillSetting}, time=$timeOfDay)';
}
