import 'package:flutter/material.dart';

/// Standard tappable option card used on Q4+ screens.
///
/// Same visual language as Q1/Q2 cards: white bg → light purple when selected,
/// purple border, optional checkmark on right.
class QOptionCard extends StatelessWidget {
  final String label;
  final String tagline;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const QOptionCard({
    super.key,
    required this.label,
    required this.tagline,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFEFFF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF534AB7)
                : const Color(0xFFE3E3DC),
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF534AB7)
                      : const Color(0xFFF3F3F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : Colors.black54,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tagline,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF534AB7), size: 22)
            else
              const Icon(Icons.chevron_right,
                  color: Colors.black26, size: 22),
          ],
        ),
      ),
    );
  }
}
