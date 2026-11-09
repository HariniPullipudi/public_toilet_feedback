import 'package:cleanspot/config/app_constants.dart';
import 'package:cleanspot/config/app_theme.dart';
import 'package:cleanspot/models/feedback_model.dart';
import 'package:cleanspot/screens/feedback/submit_feedback_screen.dart';
import 'package:cleanspot/services/supabase_service.dart';
import 'package:cleanspot/widgets/feedback_card.dart';
import 'package:flutter/material.dart';

class MyFeedbackScreen extends StatefulWidget {
  const MyFeedbackScreen({super.key});

  @override
  State<MyFeedbackScreen> createState() => _MyFeedbackScreenState();
}

class _MyFeedbackScreenState extends State<MyFeedbackScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseService _supabase = SupabaseService();
  List<FeedbackModel> _myFeedbackList = [];
  bool _isLoading = true;

  late TabController _tabController;
  final List<String> _tabs = ['All', 'Pending', 'In Progress', 'Resolved'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadMyFeedback();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMyFeedback() async {
    setState(() => _isLoading = true);
    try {
      final list = await _supabase.fetchMyFeedback();
      if (mounted) {
        setState(() {
          _myFeedbackList = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<FeedbackModel> _filterListByTab(int tabIndex) {
    if (tabIndex == 0) return _myFeedbackList;
    if (tabIndex == 1) {
      return _myFeedbackList
          .where((f) => f.status == AppConstants.statusPending)
          .toList();
    }
    if (tabIndex == 2) {
      return _myFeedbackList
          .where((f) => f.status == AppConstants.statusInProgress)
          .toList();
    }
    return _myFeedbackList
        .where((f) => f.status == AppConstants.statusResolved)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterListByTab(_tabController.index);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('My Sanitation Reports'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryDark,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMyFeedback,
        color: AppTheme.primaryColor,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
            : filtered.isEmpty
                ? ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.borderColor),
                                ),
                                child: const Icon(
                                  Icons.assignment_turned_in_outlined,
                                  size: 44,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _tabController.index == 0
                                    ? 'No reports submitted yet'
                                    : 'No ${_tabs[_tabController.index]} reports',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Your submitted feedback, issue complaints, and municipal responses will appear here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SubmitFeedbackScreen(),
                                    ),
                                  ).then((_) => _loadMyFeedback());
                                },
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Submit a Report'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return FeedbackCard(
                        feedback: item,
                        showToiletName: true,
                        isAdminView: false,
                      );
                    },
                  ),
      ),
    );
  }
}
