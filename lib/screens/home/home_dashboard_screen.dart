import 'package:cleanspot/config/app_constants.dart';
import 'package:cleanspot/config/app_theme.dart';
import 'package:cleanspot/models/feedback_model.dart';
import 'package:cleanspot/models/toilet_model.dart';
import 'package:cleanspot/screens/feedback/submit_feedback_screen.dart';
import 'package:cleanspot/screens/toilets/toilet_details_screen.dart';
import 'package:cleanspot/screens/toilets/toilet_list_screen.dart';
import 'package:cleanspot/services/supabase_service.dart';
import 'package:cleanspot/widgets/feedback_card.dart';
import 'package:cleanspot/widgets/sdg_banner.dart';
import 'package:cleanspot/widgets/toilet_card.dart';
import 'package:flutter/material.dart';

class HomeDashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeDashboardScreen({super.key, this.onNavigateTab});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final SupabaseService _supabase = SupabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<ToiletModel> _featuredToilets = [];
  List<FeedbackModel> _recentFeedback = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final toilets = await _supabase.fetchToilets();
      final feedbackList = await _supabase.fetchAllComplaintsForAdmin();

      if (mounted) {
        setState(() {
          _featuredToilets = toilets.take(3).toList();
          _recentFeedback = feedbackList.take(2).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ToiletListScreen(initialSearchQuery: query.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabase.currentUser;
    final profile = _supabase.currentProfile;
    final citizenName = profile?.fullName ??
        user?.userMetadata?['full_name'] as String? ??
        'Citizen';

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cleaning_services_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              AppConstants.appName,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Alerts',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new municipal sanitation alerts'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                'Hello, $citizenName 👋',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Let\'s build a cleaner community together.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _onSearchSubmitted,
                decoration: InputDecoration(
                  hintText: 'Search toilets by area or landmark...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.textSecondary),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: AppTheme.primaryColor),
                    onPressed: () => _onSearchSubmitted(_searchController.text),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Quick Action Buttons (Find Toilets & Report Issue)
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.explore_rounded,
                      title: 'Find Toilets',
                      subtitle: 'Nearby clean spots',
                      bgColor: AppTheme.primaryColor,
                      textColor: Colors.white,
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ToiletListScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.report_problem_rounded,
                      title: 'Report Issue',
                      subtitle: 'Photo & AI audit',
                      bgColor: const Color(0xFFDC2626),
                      textColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SubmitFeedbackScreen(
                              isUrgentReport: true,
                            ),
                          ),
                        ).then((_) => _loadDashboardData());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // UN SDG 6 Awareness Banner
              const SdgBanner(),
              const SizedBox(height: 20),

              // Featured Verified Toilets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Public Facilities',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(1);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ToiletListScreen(),
                          ),
                        );
                      }
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  ),
                )
              else if (_featuredToilets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: const Center(
                    child: Text(
                      'No toilets registered yet in your locality.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else
                ..._featuredToilets.map(
                  (toilet) => ToiletCard(
                    toilet: toilet,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ToiletDetailsScreen(toilet: toilet),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),

              // Recent Community Feedback
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Community Reports',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(2);
                      }
                    },
                    child: const Text('My Reports'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_recentFeedback.isNotEmpty)
                ..._recentFeedback.map(
                  (feedback) => FeedbackCard(
                    feedback: feedback,
                    showToiletName: true,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: const Center(
                    child: Text(
                      'No reports yet. Be the first to submit hygiene feedback!',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            child: Row(
              children: [
                Icon(icon, size: 28, color: textColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: textColor.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
