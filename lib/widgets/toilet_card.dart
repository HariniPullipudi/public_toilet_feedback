import 'package:cleanspot/config/app_theme.dart';
import 'package:cleanspot/models/toilet_model.dart';
import 'package:cleanspot/services/location_service.dart';
import 'package:cleanspot/widgets/cleanliness_indicator.dart';
import 'package:cleanspot/widgets/star_rating_bar.dart';
import 'package:flutter/material.dart';

class ToiletCard extends StatelessWidget {
  final ToiletModel toilet;
  final VoidCallback onTap;

  const ToiletCard({
    super.key,
    required this.toilet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Name and Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            toilet.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  toilet.address,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    CleanlinessIndicator(rating: toilet.averageRating, compact: true),
                  ],
                ),
                const SizedBox(height: 12),

                // Rating and Distance row
                Row(
                  children: [
                    StarRatingBar(
                      rating: toilet.averageRating,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${toilet.reviewCount} reviews)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (toilet.distanceKm != null) ...[
                      const Icon(
                        Icons.directions_walk_rounded,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        LocationService.formatDistance(toilet.distanceKm),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppTheme.dividerColor),
                const SizedBox(height: 10),

                // Facility Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (toilet.waterAvailable)
                      _buildChip(
                        icon: Icons.water_drop_outlined,
                        label: 'Running Water',
                        color: const Color(0xFF0284C7),
                        bgColor: const Color(0xFFE0F2FE),
                      ),
                    if (toilet.soapAvailable)
                      _buildChip(
                        icon: Icons.sanitizer_outlined,
                        label: 'Soap Dispenser',
                        color: const Color(0xFF059669),
                        bgColor: const Color(0xFFD1FAE5),
                      ),
                    if (toilet.wheelchairAccessible)
                      _buildChip(
                        icon: Icons.accessible_rounded,
                        label: 'Accessible',
                        color: const Color(0xFF7C3AED),
                        bgColor: const Color(0xFFEDE9FE),
                      ),
                    if (toilet.isVerified)
                      _buildChip(
                        icon: Icons.verified_user_outlined,
                        label: 'Verified Facility',
                        color: AppTheme.primaryDark,
                        bgColor: AppTheme.scaffoldBackground,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
