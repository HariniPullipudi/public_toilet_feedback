import 'package:cleanspot/config/app_theme.dart';
import 'package:cleanspot/screens/admin/admin_dashboard_screen.dart';
import 'package:cleanspot/screens/feedback/my_feedback_screen.dart';
import 'package:cleanspot/screens/feedback/submit_feedback_screen.dart';
import 'package:cleanspot/screens/home/home_dashboard_screen.dart';
import 'package:cleanspot/screens/profile/profile_screen.dart';
import 'package:cleanspot/screens/toilets/toilet_list_screen.dart';
import 'package:cleanspot/services/supabase_service.dart';
import 'package:flutter/material.dart';

class MainNavScaffold extends StatefulWidget {
  final int initialIndex;

  const MainNavScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends State<MainNavScaffold> {
  late int _currentIndex;
  final SupabaseService _supabase = SupabaseService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _supabase.isAdmin;

    final List<Widget> screens = [
      HomeDashboardScreen(onNavigateTab: _onTabTapped),
      const ToiletListScreen(),
      const SubmitFeedbackScreen(),
      const MyFeedbackScreen(),
      if (isAdmin) const AdminDashboardScreen(),
      const ProfileScreen(),
    ];

    final List<NavigationDestination> destinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryDark),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore_rounded, color: AppTheme.primaryDark),
        label: 'Toilets',
      ),
      const NavigationDestination(
        icon: Icon(Icons.add_circle_outline_rounded),
        selectedIcon: Icon(Icons.add_circle_rounded, color: AppTheme.primaryDark),
        label: 'Report',
      ),
      const NavigationDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment_rounded, color: AppTheme.primaryDark),
        label: 'Reports',
      ),
      if (isAdmin)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon:
              Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primaryDark),
          label: 'Admin',
        ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryDark),
        label: 'Profile',
      ),
    ];

    final safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: _onTabTapped,
        backgroundColor: Colors.white,
        elevation: 4,
        indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.15),
        destinations: destinations,
      ),
    );
  }
}
