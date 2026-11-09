import 'package:flutter/material.dart';

class CleanlinessIndicator extends StatelessWidget {
  final double rating;
  final bool compact;

  const CleanlinessIndicator({
    super.key,
    required this.rating,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    String label;
    IconData icon;

    if (rating >= 4.2) {
      bg = const Color(0xFFE8F5E9); // Light green
      textColor = const Color(0xFF2E7D32); // Dark green
      label = 'Clean & Sanitized';
      icon = Icons.verified_rounded;
    } else if (rating >= 3.0) {
      bg = const Color(0xFFE0F2FE); // Light sky blue
      textColor = const Color(0xFF0369A1); // Deep blue
      label = 'Moderate Condition';
      icon = Icons.info_outline_rounded;
    } else {
      bg = const Color(0xFFFEE2E2); // Light red
      textColor = const Color(0xFFDC2626); // Dark red
      label = 'Needs Maintenance';
      icon = Icons.warning_amber_rounded;
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
