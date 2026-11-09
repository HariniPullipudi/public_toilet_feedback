import 'package:cleanspot/config/app_constants.dart';
import 'package:cleanspot/config/app_theme.dart';
import 'package:cleanspot/models/feedback_model.dart';
import 'package:cleanspot/models/toilet_model.dart';
import 'package:cleanspot/services/supabase_service.dart';
import 'package:cleanspot/widgets/feedback_card.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final SupabaseService _supabase = SupabaseService();

  List<FeedbackModel> _complaints = [];
  List<ToiletModel> _toilets = [];
  bool _isLoading = true;

  // Filters
  String _selectedStatusFilter = 'All';
  String _selectedCategoryFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    try {
      final toilets = await _supabase.fetchToilets();
      final complaints = await _supabase.fetchAllComplaintsForAdmin();

      if (mounted) {
        setState(() {
          _toilets = toilets;
          _complaints = complaints;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showStatusUpdateDialog(FeedbackModel feedback) {
    String newStatus = feedback.status;
    final responseController =
        TextEditingController(text: feedback.adminResponse ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Manage Complaint Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Facility: ${feedback.toiletName ?? "Unknown"} • ${feedback.issueCategory}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status Dropdown
                    const Text(
                      'Update Complaint State',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.scaffoldBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: newStatus,
                          isExpanded: true,
                          items: [
                            AppConstants.statusPending,
                            AppConstants.statusInProgress,
                            AppConstants.statusResolved,
                            AppConstants.statusRejected,
                          ].map((st) {
                            return DropdownMenuItem<String>(
                              value: st,
                              child: Text(
                                AppConstants.formatStatus(st),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => newStatus = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Response input
                    const Text(
                      'Sanitation Supervisor Response',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: responseController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'e.g. Cleaning crew dispatched; taps repaired; bins emptied...',
                        filled: true,
                        fillColor: AppTheme.scaffoldBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit update
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          try {
                            await _supabase.updateComplaintStatus(
                              feedbackId: feedback.id,
                              status: newStatus,
                              adminResponse: responseController.text.trim(),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Complaint status updated successfully!'),
                                  backgroundColor: AppTheme.primaryDark,
                                ),
                              );
                            }
                            _loadAdminData();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error updating status: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Save & Publish Response'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Statistics Calculations
    final totalToilets = _toilets.length;
    final totalFeedback = _complaints.length;
    final pendingCount = _complaints.where((c) => c.isPending).length;
    final inProgressCount = _complaints.where((c) => c.isInProgress).length;
    final resolvedCount = _complaints.where((c) => c.isResolved).length;

    // Filtered Complaints
    final filteredComplaints = _complaints.where((c) {
      final matchesStatus = _selectedStatusFilter == 'All' ||
          c.status.toLowerCase() == _selectedStatusFilter.toLowerCase();
      final matchesCategory = _selectedCategoryFilter == 'All' ||
          c.issueCategory == _selectedCategoryFilter;
      return matchesStatus && matchesCategory;
    }).toList();

    // Low Rated Toilets
    final lowRatedToilets =
        _toilets.where((t) => t.averageRating < 3.2).toList();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Sanitation Authority Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAdminData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAdminData,
        color: AppTheme.primaryColor,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Municipal Sanitation Dashboard',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'SDG 6 Compliance • Facility Audits & Fast Response',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Metrics Grid (4 cards)
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Facilities',
                            totalToilets.toString(),
                            Icons.location_city_rounded,
                            const Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            'Total Reports',
                            totalFeedback.toString(),
                            Icons.rate_review_rounded,
                            AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Pending',
                            pendingCount.toString(),
                            Icons.pending_actions_rounded,
                            AppTheme.statusPending,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            'In Progress',
                            inProgressCount.toString(),
                            Icons.engineering_rounded,
                            AppTheme.statusInProgress,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            'Resolved',
                            resolvedCount.toString(),
                            Icons.verified_rounded,
                            AppTheme.statusResolved,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Low-Rated Toilets Alert
                    if (lowRatedToilets.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFDC2626), size: 20),
                          const SizedBox(width: 6),
                          const Text(
                            'Attention Required (Rating < 3.2)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...lowRatedToilets.map(
                        (toilet) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: Color(0xFFDC2626), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      toilet.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Average Rating: ${toilet.averageRating} ★ (${toilet.reviewCount} complaints)',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF991B1B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Complaints Filter Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Public Complaints Stream',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${filteredComplaints.length} reports',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Status Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusFilterChip('All'),
                          const SizedBox(width: 6),
                          _buildStatusFilterChip(AppConstants.statusPending),
                          const SizedBox(width: 6),
                          _buildStatusFilterChip(AppConstants.statusInProgress),
                          const SizedBox(width: 6),
                          _buildStatusFilterChip(AppConstants.statusResolved),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Category Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All Categories'),
                            selected: _selectedCategoryFilter == 'All',
                            onSelected: (val) {
                              setState(() => _selectedCategoryFilter = 'All');
                            },
                          ),
                          ...AppConstants.issueCategories.map(
                            (cat) => Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: FilterChip(
                                label: Text(cat),
                                selected: _selectedCategoryFilter == cat,
                                onSelected: (val) {
                                  setState(() => _selectedCategoryFilter = cat);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Complaint cards
                    if (filteredComplaints.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: const Text(
                          'No complaints matching the selected filters.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )
                    else
                      ...filteredComplaints.map(
                        (complaint) => FeedbackCard(
                          feedback: complaint,
                          showToiletName: true,
                          isAdminView: true,
                          onAdminAction: () => _showStatusUpdateDialog(complaint),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusFilterChip(String status) {
    final isSelected = _selectedStatusFilter.toLowerCase() == status.toLowerCase();
    return FilterChip(
      label: Text(AppConstants.formatStatus(status)),
      selected: isSelected,
      onSelected: (val) {
        setState(() {
          _selectedStatusFilter = status;
        });
      },
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
