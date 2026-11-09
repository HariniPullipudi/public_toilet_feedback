import 'package:cleanspot/config/app_theme.dart';
import 'package:cleanspot/models/feedback_model.dart';
import 'package:cleanspot/models/toilet_model.dart';
import 'package:cleanspot/screens/feedback/submit_feedback_screen.dart';
import 'package:cleanspot/services/location_service.dart';
import 'package:cleanspot/services/supabase_service.dart';
import 'package:cleanspot/widgets/cleanliness_indicator.dart';
import 'package:cleanspot/widgets/feedback_card.dart';
import 'package:cleanspot/widgets/star_rating_bar.dart';
import 'package:flutter/material.dart';

class ToiletDetailsScreen extends StatefulWidget {
  final ToiletModel toilet;

  const ToiletDetailsScreen({super.key, required this.toilet});

  @override
  State<ToiletDetailsScreen> createState() => _ToiletDetailsScreenState();
}

class _ToiletDetailsScreenState extends State<ToiletDetailsScreen> {
  final SupabaseService _supabase = SupabaseService();
  List<FeedbackModel> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final reviews = await _supabase.fetchFeedbackForToilet(widget.toilet.id);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
    }
  }

  void _navigateToFeedback({bool isReport = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubmitFeedbackScreen(
          preselectedToilet: widget.toilet,
          isUrgentReport: isReport,
        ),
      ),
    ).then((_) => _loadReviews());
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.toilet;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Facility Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Facility Info',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing ${t.name} details'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    t.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CleanlinessIndicator(rating: t.averageRating),
              ],
            ),
            const SizedBox(height: 6),

            // Address & Distance
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t.address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            if (t.distanceKm != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.directions_walk_rounded,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    LocationService.formatDistance(t.distanceKm),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Average Rating Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      StarRatingBar(rating: t.averageRating, size: 18),
                      const SizedBox(height: 4),
                      Text(
                        '${t.reviewCount} community evaluations',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 1,
                    height: 50,
                    color: AppTheme.dividerColor,
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingRow('Cleanliness', t.averageRating),
                      const SizedBox(height: 4),
                      _buildRatingRow('Water Supply', t.waterAvailable ? 4.5 : 2.0),
                      const SizedBox(height: 4),
                      _buildRatingRow('Accessibility', t.wheelchairAccessible ? 5.0 : 2.5),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Facilities & Amenities section
            const Text(
              'Facility Amenities & Hygiene',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildAmenityTile(
                    icon: Icons.water_drop_outlined,
                    label: 'Running Water',
                    isAvailable: t.waterAvailable,
                    activeColor: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAmenityTile(
                    icon: Icons.sanitizer_outlined,
                    label: 'Soap Dispenser',
                    isAvailable: t.soapAvailable,
                    activeColor: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildAmenityTile(
                    icon: Icons.accessible_rounded,
                    label: 'Wheelchair Ramp',
                    isAvailable: t.wheelchairAccessible,
                    activeColor: const Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAmenityTile(
                    icon: Icons.verified_user_outlined,
                    label: 'Public Audit',
                    isAvailable: t.isVerified,
                    activeColor: AppTheme.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Description
            if (t.description.isNotEmpty) ...[
              const Text(
                'About this Facility',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Text(
                  t.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Action Buttons: Submit Feedback & Report Issue
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToFeedback(isReport: false),
                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                    label: const Text('Rate Facility'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToFeedback(isReport: true),
                    icon: const Icon(Icons.report_problem_outlined, size: 18),
                    label: const Text('Report Issue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Community Feedback & Reviews
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Community Reviews',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${_reviews.length} total',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_isLoadingReviews)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                ),
              )
            else if (_reviews.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 40,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No reviews submitted yet',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Be the first citizen to inspect and rate this public facility.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => _navigateToFeedback(isReport: false),
                      icon: const Icon(Icons.add_comment_outlined, size: 18),
                      label: const Text('Add Review'),
                    ),
                  ],
                ),
              )
            else
              ..._reviews.map(
                (rev) => FeedbackCard(
                  feedback: rev,
                  showToiletName: false,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(String title, double score) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
        Text(
          score.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityTile({
    required IconData icon,
    required String label,
    required bool isAvailable,
    required Color activeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable ? activeColor.withValues(alpha: 0.3) : AppTheme.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isAvailable
                  ? activeColor.withValues(alpha: 0.12)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: isAvailable ? activeColor : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isAvailable ? activeColor : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
