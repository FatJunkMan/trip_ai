import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trip_ai/models/models.dart';
import 'package:trip_ai/state/answers.dart';
import 'package:trip_ai/services/api.dart';
import 'package:trip_ai/widgets/loading_overlay.dart';

/// Result screen: shows the recommended venue or the no-matches state.
///
/// Receives a PlanResult via Navigator route arguments.
/// Branches on PlanOk vs PlanEmpty.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _retrying = false;

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    final answers = context.read<AnswersState>();
    try {
      final result = await api.plan(answers.toRequestPayload());
      if (!mounted) return;
      // Replace current route so back-button doesn't revisit the empty state
      Navigator.of(context).pushReplacementNamed('/result', arguments: result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t reach server: $e')),
      );
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ModalRoute.of(context)?.settings.arguments as PlanResult?;
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
      body: Stack(
        children: [
          if (result is PlanOk)
            _ResultOk(plan: result)
          else if (result is PlanEmpty)
            _ResultEmpty(empty: result, onRetry: _retry)
          else
            const Center(child: Text('No result available.')),
          if (_retrying)
            const LoadingOverlay(message: "Trying again..."),
        ],
      ),
    );
  }
}

// ============================================================
// PlanOk: a recommended venue
// ============================================================

class _ResultOk extends StatelessWidget {
  final PlanOk plan;
  const _ResultOk({required this.plan});

  @override
  Widget build(BuildContext context) {
    final v = plan.venue;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'YOUR SPOT',
              style: TextStyle(
                fontSize: 11,
                color: Colors.black54,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _PhotoPlaceholder(venue: v),
            const SizedBox(height: 16),
            // Name
            Text(
              v.nameEn,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              v.nameAr,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            // Type · neighborhood
            Text(
              '${_humanizeType(v.venueType)} · ${v.neighborhood}',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            // Vibe chips
            if (v.vibeTags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: v.vibeTags
                    .take(4)
                    .map((t) => _VibeChip(
                          label: t,
                          highlighted:
                              plan.matchSummary.matchedTags.contains(t),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),
            // Why this one
            _WhyThisOne(text: plan.matchSummary.whyThisOne),
            const SizedBox(height: 16),
            // Info row: price | hours | rating
            _InfoRow(venue: v),
            const SizedBox(height: 16),
            // Curator note
            if (v.curatorNote != null && v.curatorNote!.isNotEmpty)
              _CuratorNote(text: v.curatorNote!),
            if (v.curatorNote != null && v.curatorNote!.isNotEmpty)
              const SizedBox(height: 16),
            // Badges
            _BadgeRow(venue: v),
            const SizedBox(height: 20),
            // Action buttons row
            _ActionRow(venue: v),
            const SizedBox(height: 14),
            // Save this plan button (full-width, primary style)
            _SaveTripButton(venue: v),
            const SizedBox(height: 28),
            // Alternatives buttons
            _AlternativesButton(
              label: 'Show alternatives',
              icon: Icons.swap_horiz,
              onTap: () => Navigator.of(context).pushNamed(
                '/alternatives',
                arguments: AlternativesArgs(
                  alcoholOnly: false,
                  // Match the current venue's alcohol policy: if this pick
                  // is non-alcohol, alternatives are also non-alcohol.
                  // Keeps the list consistent with the user's preference.
                  nonAlcoholOnly: !v.servesAlcohol,
                  excludeIds: [v.venueId],
                ),
              ),
            ),
            if (plan.alcoholAlternatives.available) ...[
              const SizedBox(height: 10),
              _AlternativesButton(
                label: 'Show alcohol alternatives',
                icon: Icons.local_bar_outlined,
                onTap: () => Navigator.of(context).pushNamed(
                  '/alternatives',
                  arguments: AlternativesArgs(
                    alcoholOnly: true,
                    excludeIds: [v.venueId],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _humanizeType(String t) {
    return t.split('_').map((w) => w.isEmpty
        ? ''
        : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  final VenueCardModel venue;
  const _PhotoPlaceholder({required this.venue});

  @override
  Widget build(BuildContext context) {
    final colors = _gradientForType(venue.venueType);
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Text(
          venue.nameEn.isEmpty ? '?' : venue.nameEn[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gradient picked by venue type for a tiny bit of visual variety.
  List<Color> _gradientForType(String type) {
    if (type.contains('cafe') || type.contains('coffee')) {
      return const [Color(0xFF7A4FA8), Color(0xFFC09BE8)];
    }
    if (type.contains('restaurant') || type == 'shawarma') {
      return const [Color(0xFFE07A5F), Color(0xFFF4B292)];
    }
    if (type.contains('park') || type.contains('reserve') ||
        type.contains('hike') || type.contains('beach')) {
      return const [Color(0xFF3D8A6B), Color(0xFF7AB89C)];
    }
    if (type.contains('archaeo') || type == 'castle' ||
        type.contains('historic') || type == 'museum' || type == 'religious_site') {
      return const [Color(0xFFB07A2F), Color(0xFFE2BC7E)];
    }
    if (type.contains('rooftop') || type.contains('bar')) {
      return const [Color(0xFF534AB7), Color(0xFF8C84D8)];
    }
    return const [Color(0xFF534AB7), Color(0xFF8C84D8)];
  }
}

class _VibeChip extends StatelessWidget {
  final String label;
  final bool highlighted;
  const _VibeChip({required this.label, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:
            highlighted ? const Color(0xFFEFEFFF) : const Color(0xFFF3F3F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted
              ? const Color(0xFF534AB7)
              : const Color(0xFFE3E3DC),
          width: 0.5,
        ),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color:
              highlighted ? const Color(0xFF534AB7) : Colors.black54,
        ),
      ),
    );
  }
}

class _WhyThisOne extends StatelessWidget {
  final String text;
  const _WhyThisOne({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFFF),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF534AB7).withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome,
              size: 16, color: Color(0xFF534AB7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Color(0xFF332C8A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final VenueCardModel venue;
  const _InfoRow({required this.venue});

  @override
  Widget build(BuildContext context) {
    final priceLabel = venue.priceTier == 0
        ? 'Free'
        : (venue.priceNoteJd ?? '\$' * (venue.priceTier));
    final hoursLabel = venue.hoursToday == null
        ? 'Hours unknown'
        : '${venue.hoursToday!.opens}–${venue.hoursToday!.closes}';
    final ratingLabel = venue.googleRating == null
        ? 'No rating'
        : '${venue.googleRating!.toStringAsFixed(1)} ★';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E3DC), width: 0.5),
      ),
      child: Row(
        children: [
          _InfoCell(
            icon: Icons.payments_outlined,
            label: 'Price',
            value: priceLabel,
          ),
          _InfoDivider(),
          _InfoCell(
            icon: Icons.schedule,
            label: 'Hours today',
            value: hoursLabel,
          ),
          _InfoDivider(),
          _InfoCell(
            icon: Icons.star_outline,
            label: 'Rating',
            value: ratingLabel,
          ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 36,
      color: const Color(0xFFE3E3DC),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CuratorNote extends StatelessWidget {
  final String text;
  const _CuratorNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF1DF),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: const Color(0xFFB07A2F), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURATOR NOTE',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFFB07A2F),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final VenueCardModel venue;
  const _BadgeRow({required this.venue});

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];
    if (venue.verifiedByAj) {
      badges.add(_Badge(
        icon: Icons.verified_outlined,
        label: 'Verified',
        color: const Color(0xFF3D8A6B),
      ));
    }
    if (venue.wheelchairAccessible == 'Y') {
      badges.add(_Badge(
        icon: Icons.accessible,
        label: 'Accessible',
        color: const Color(0xFF534AB7),
      ));
    }
    if (venue.hasView) {
      badges.add(_Badge(
        icon: Icons.visibility_outlined,
        label: 'View',
        color: const Color(0xFFB07A2F),
      ));
    }
    if (venue.servesAlcohol) {
      badges.add(_Badge(
        icon: Icons.local_bar_outlined,
        label: 'Alcohol',
        color: const Color(0xFF7A4FA8),
      ));
    }
    if (badges.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: badges);
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final VenueCardModel venue;
  const _ActionRow({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.map_outlined,
            label: 'Open in Maps',
            onTap: () async {
              final uri = Uri.parse(venue.googleMapsUrl);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
        ),
        if (venue.reservationPhone != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              icon: Icons.call_outlined,
              label: 'Call',
              onTap: () async {
                final cleaned = venue.reservationPhone!
                    .replaceAll(RegExp(r'\s+'), '');
                final uri = Uri.parse('tel:$cleaned');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE3E3DC), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF534AB7)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF534AB7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlternativesButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _AlternativesButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF534AB7),
          side: const BorderSide(color: Color(0xFF534AB7), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

// ============================================================
// PlanEmpty: relaxation chip UI
// ============================================================

class _ResultEmpty extends StatelessWidget {
  final PlanEmpty empty;
  final Future<void> Function() onRetry;
  const _ResultEmpty({required this.empty, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.search_off_outlined,
                size: 56, color: Colors.black38),
            const SizedBox(height: 16),
            const Text(
              "No spot matched everything.",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              empty.reason,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            const Text(
              "TRY RELAXING",
              style: TextStyle(
                fontSize: 11,
                color: Colors.black54,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            ...empty.suggestions.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SuggestionChip(
                  suggestion: s,
                  onTap: () async {
                    final answers = context.read<AnswersState>();
                    _applyTweak(answers, s.tweak);
                    await onRetry();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyTweak(AnswersState answers, String tweak) {
    answers.update(() {
      switch (tweak) {
        case 'raise_budget':
          if ((answers.budgetTier ?? 0) < 4) {
            answers.budgetTier = (answers.budgetTier ?? 0) + 1;
          }
          break;
        case 'broaden_audience':
          answers.audience = 'mixed';
          break;
        case 'drop_wheelchair_strict':
          answers.wheelchairUser = false;
          break;
      }
    });
  }
}

class _SuggestionChip extends StatelessWidget {
  final Suggestion suggestion;
  final VoidCallback onTap;
  const _SuggestionChip({required this.suggestion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE3E3DC), width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.tune, size: 18, color: Color(0xFF534AB7)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion.labelEn,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

/// Save-this-plan button. Stateful so we can show idle/saving/saved states.
/// Once saved, the button becomes a "Saved" badge that's tappable again
/// to save a fresh entry (e.g. if the user wants to mark this venue twice
/// for whatever reason — rare, but cheap to allow).
class _SaveTripButton extends StatefulWidget {
  final VenueCardModel venue;
  const _SaveTripButton({required this.venue});

  @override
  State<_SaveTripButton> createState() => _SaveTripButtonState();
}

class _SaveTripButtonState extends State<_SaveTripButton> {
  bool _saving = false;
  bool _saved = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final answers = context.read<AnswersState>();
      await api.saveTrip(
        answers: answers.toRequestPayload()['answers'] as Map<String, dynamic>,
        venue: widget.venue,
      );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Saved to your trips"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't save: ${e.message}")),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't save: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(_saved ? Icons.check : Icons.bookmark_outline, size: 18),
        label: Text(_saved ? 'Saved' : 'Save this plan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF534AB7),
          disabledBackgroundColor: const Color(0xFF8C84D8),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Arguments class for the /alternatives route — distinguishes regular
/// alternatives from the alcohol-only variant and carries the exclusion list.
class AlternativesArgs {
  final bool alcoholOnly;
  final bool nonAlcoholOnly;
  final List<String> excludeIds;
  const AlternativesArgs({
    required this.alcoholOnly,
    required this.excludeIds,
    this.nonAlcoholOnly = false,
  });
}
