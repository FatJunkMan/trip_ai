import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_ai/state/answers.dart';

/// Q2: Group composition.
///
/// Three controls on one screen:
///   - Group size counter (1 to 30, default 4)
///   - Audience picker (couples / families / singles / mixed)
///   - Wheelchair-user toggle
///
/// Audience validity rules (slice 5.5):
///   - Couples: size must be >= 2 AND even
///   - Families: size must be >= 3
///   - Singles, Mixed: any size
/// If the user changes group size such that the currently-selected audience
/// becomes invalid, the audience is silently cleared and Continue disables.
class Q2GroupScreen extends StatelessWidget {
  const Q2GroupScreen({super.key});

  static const _audienceOptions = <_AudienceOption>[
    _AudienceOption(
      'couples', 'Couples',
      'Date-friendly, romantic vibes welcome',
      Icons.favorite_outline,
    ),
    _AudienceOption(
      'families', 'Families',
      'Kids welcome, family-friendly settings',
      Icons.escalator_warning,
    ),
    _AudienceOption(
      'singles', 'Singles',
      'Solo or social — anywhere goes',
      Icons.person_outline,
    ),
    _AudienceOption(
      'mixed', 'Mixed',
      "A bit of everything — couples, friends, anyone",
      Icons.groups_outlined,
    ),
  ];

  /// Returns null if [audience] is valid for [size], otherwise a hint string
  /// explaining the constraint.
  static String? _invalidReason(String audience, int size) {
    switch (audience) {
      case 'couples':
        if (size < 2 || size % 2 != 0) {
          return 'Couples come in pairs — try 2, 4, 6…';
        }
        return null;
      case 'families':
        if (size < 3) {
          return 'Family hangouts need 3+ people';
        }
        return null;
      case 'singles':
      case 'mixed':
        return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final answers = context.watch<AnswersState>();
    final size = answers.groupSize ?? 4;

    // Auto-clear audience if it became invalid due to size change.
    // Done in a post-frame callback to avoid setState-during-build.
    if (answers.audience != null &&
        _invalidReason(answers.audience!, size) != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        answers.update(() => answers.audience = null);
      });
    }

    final canContinue = answers.audience != null &&
        _invalidReason(answers.audience!, size) == null;

    // Default group size to 4 if unset (first-time arrival).
    if (answers.groupSize == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        answers.update(() => answers.groupSize = 4);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Question 2',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Who's coming?",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _GroupSizeControl(
                      size: size,
                      onChanged: (v) =>
                          answers.update(() => answers.groupSize = v),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'WHO',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._audienceOptions.map((opt) {
                      final invalidHint = _invalidReason(opt.key, size);
                      final isDisabled = invalidHint != null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AudienceCard(
                          option: opt,
                          selected: answers.audience == opt.key,
                          disabled: isDisabled,
                          disabledHint: invalidHint,
                          onTap: isDisabled
                              ? null
                              : () => answers.update(
                                  () => answers.audience = opt.key),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    _WheelchairToggle(
                      value: answers.wheelchairUser,
                      onChanged: (v) =>
                          answers.update(() => answers.wheelchairUser = v),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canContinue
                      ? () =>
                          Navigator.of(context).pushNamed('/q3-main-thing')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF534AB7),
                    disabledBackgroundColor: const Color(0xFFD8D5EC),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudienceOption {
  final String key;
  final String label;
  final String description;
  final IconData icon;
  const _AudienceOption(this.key, this.label, this.description, this.icon);
}

class _GroupSizeControl extends StatelessWidget {
  final int size;
  final ValueChanged<int> onChanged;
  const _GroupSizeControl({required this.size, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E3DC), width: 0.5),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Group size',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'How many people in total',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          _CounterButton(
            icon: Icons.remove,
            enabled: size > 1,
            onTap: () => onChanged((size - 1).clamp(1, 30)),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '$size',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.add,
            enabled: size < 30,
            onTap: () => onChanged((size + 1).clamp(1, 30)),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _CounterButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFEFEFFF) : const Color(0xFFF3F3F0),
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled
                ? const Color(0xFF534AB7).withOpacity(0.3)
                : const Color(0xFFE3E3DC),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFF534AB7) : Colors.black26,
          size: 18,
        ),
      ),
    );
  }
}

class _AudienceCard extends StatelessWidget {
  final _AudienceOption option;
  final bool selected;
  final bool disabled;
  final String? disabledHint;
  final VoidCallback? onTap;

  const _AudienceCard({
    required this.option,
    required this.selected,
    required this.disabled,
    required this.disabledHint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Visual states:
    //   disabled: dimmed background, dimmed text, no chevron, hint shown
    //   selected: purple border, light purple bg, check
    //   default:  white bg, light grey border
    final Color bg;
    final Color borderColor;
    final double borderWidth;
    if (disabled) {
      bg = const Color(0xFFF3F3F0);
      borderColor = const Color(0xFFE3E3DC);
      borderWidth = 0.5;
    } else if (selected) {
      bg = const Color(0xFFEFEFFF);
      borderColor = const Color(0xFF534AB7);
      borderWidth = 1.5;
    } else {
      bg = Colors.white;
      borderColor = const Color(0xFFE3E3DC);
      borderWidth = 0.5;
    }

    final textColor = disabled ? Colors.black38 : Colors.black87;
    final secondaryColor = disabled ? Colors.black26 : Colors.black54;
    final iconBg = disabled
        ? const Color(0xFFE8E8E0)
        : (selected ? const Color(0xFF534AB7) : const Color(0xFFF3F3F0));
    final iconColor = disabled
        ? Colors.black26
        : (selected ? Colors.white : Colors.black54);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(option.icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // Show the constraint hint when disabled, otherwise the
                    // normal description.
                    disabled ? disabledHint! : option.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: disabled
                          ? const Color(0xFFB07A2F) // amber-ish hint colour
                          : secondaryColor,
                      fontStyle: disabled ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (!disabled && selected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF534AB7), size: 22),
          ],
        ),
      ),
    );
  }
}

class _WheelchairToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _WheelchairToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value
                ? const Color(0xFF534AB7)
                : const Color(0xFFE3E3DC),
            width: value ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.accessible,
              color: value ? const Color(0xFF534AB7) : Colors.black54,
              size: 22,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wheelchair user in group',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "We'll only show wheelchair-accessible venues",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF534AB7),
            ),
          ],
        ),
      ),
    );
  }
}
