import 'package:cleanspot/config/app_constants.dart';
import 'package:cleanspot/config/app_theme.dart';
import 'package:cleanspot/models/feedback_model.dart';
import 'package:cleanspot/widgets/star_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedbackCard extends StatelessWidget {
  final FeedbackModel feedback;
  final bool showToiletName;
  final bool isAdminView;
  final VoidCallback? onAdminAction;

  const FeedbackCard({
    super.key,
    required this.feedback,
    this.showToiletName = true,
    this.isAdminView = false,
    this.onAdminAction,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case AppConstants.statusPending:
        return AppTheme.statusPending;
      case AppConstants.statusInProgress:
        return AppTheme.statusInProgress;
      case AppConstants.statusResolved:
        return AppTheme.statusResolved;
      case AppConstants.statusRejected:
        return AppTheme.statusRejected;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case AppConstants.statusPending:
        return const Color(0xFFFEF3C7);
      case AppConstants.statusInProgress:
        return const Color(0xFFDBEAFE);
      case AppConstants.statusResolved:
        return const Color(0xFFD1FAE5);
      case AppConstants.statusRejected:
        return const Color(0xFFFEE2E2);
      default:
        return AppTheme.scaffoldBackground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(feedback.status);
    final statusBg = _getStatusBgColor(feedback.status);
    final formattedDate =
        DateFormat('MMM dd, yyyy • hh:mm a').format(feedback.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category and Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.scaffoldBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Text(
                  feedback.issueCategory,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      AppConstants.formatStatus(feedback.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Toilet Name (if specified)
          if (showToiletName && feedback.toiletName != null) ...[
            Text(
              feedback.toiletName!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
          ],

          // Rating and Date
          Row(
            children: [
              StarRatingBar(
                rating: feedback.overallRating.toDouble(),
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                '${feedback.overallRating}.0',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // User Comments
          if (feedback.comments.isNotEmpty) ...[
            Text(
              feedback.comments,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Photo preview (if present)
          if (feedback.photoPath != null && feedback.photoPath!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                feedback.photoPath!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 60,
                  color: AppTheme.scaffoldBackground,
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_outlined, size: 16, color: AppTheme.textMuted),
                      SizedBox(width: 6),
                      Text(
                        'Attached image preview',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Admin Response Section
          if (feedback.adminResponse != null &&
              feedback.adminResponse!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 16,
                    color: Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sanitation Authority Response:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          feedback.adminResponse!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF166534),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Admin action button
          if (isAdminView && onAdminAction != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAdminAction,
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                label: const Text('Update Status & Respond'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
