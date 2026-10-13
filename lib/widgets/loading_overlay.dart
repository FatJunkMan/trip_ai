import 'package:flutter/material.dart';

/// Subtle centered overlay used while a network request is in flight.
///
/// Designed to be wrapped in a Stack with the screen's main content as a
/// sibling. The screen toggles this overlay's visibility based on its own
/// loading state.
///
/// Usage:
/// ```dart
/// Stack(children: [
///   QScaffold(...),
///   if (_loading) const LoadingOverlay(message: "Finding your spot..."),
/// ])
/// ```
class LoadingOverlay extends StatelessWidget {
  final String message;
  const LoadingOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFFF7F7F5).withOpacity(0.6),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF534AB7)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
