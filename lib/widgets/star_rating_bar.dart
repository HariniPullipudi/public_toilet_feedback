import 'package:flutter/material.dart';

class StarRatingBar extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color color;
  final Color unratedColor;
  final ValueChanged<int>? onRatingChanged;
  final bool isInteractive;

  const StarRatingBar({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.color = const Color(0xFFF59E0B),
    this.unratedColor = const Color(0xFFCBD5E1),
    this.onRatingChanged,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starIndex = index + 1;
        IconData iconData;
        Color starColor;

        if (rating >= starIndex) {
          iconData = Icons.star_rounded;
          starColor = color;
        } else if (rating >= starIndex - 0.5) {
          iconData = Icons.star_half_rounded;
          starColor = color;
        } else {
          iconData = Icons.star_outline_rounded;
          starColor = unratedColor;
        }

        final star = Icon(
          iconData,
          size: size,
          color: starColor,
        );

        if (isInteractive) {
          return InkWell(
            onTap: onRatingChanged != null ? () => onRatingChanged!(starIndex) : null,
            borderRadius: BorderRadius.circular(size),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: star,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: star,
        );
      }),
    );
  }
}
