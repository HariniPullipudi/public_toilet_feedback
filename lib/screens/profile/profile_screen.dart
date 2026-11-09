import 'package:cleanspot/config/app_constants.dart';
import 'package:cleanspot/config/app_theme.dart';
import 'package:cleanspot/config/supabase_config.dart';
import 'package:cleanspot/screens/auth/login_screen.dart';
import 'package:cleanspot/screens/feedback/my_feedback_screen.dart';
import 'package:cleanspot/services/supabase_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _supabase = SupabaseService();

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to sign out of CleanSpot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusRejected,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _supabase.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabase.currentUser;
    final profile = _supabase.currentProfile;
    final isAdmin = _supabase.isAdmin;

    final displayName = profile?.fullName ??
        user?.userMetadata?['full_name'] as String? ??
        (user != null ? 'Citizen Member' : 'Guest Citizen');
    final email = user?.email ?? 'Testing / Guest Mode';

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName.substring(0, 1).toUpperCase()
                          : 'C',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: isAdmin
                          ? const Color(0xFFEDE9FE)
                          : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAdmin
                              ? Icons.admin_panel_settings_rounded
                              : Icons.verified_user_rounded,
                          size: 14,
                          color: isAdmin
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isAdmin ? 'Municipal Administrator' : 'Verified Citizen',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isAdmin
                                ? const Color(0xFF6D28D9)
                                : const Color(0xFF0369A1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SDG 6 Citizen Civic Score Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00695C), AppTheme.primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFFBBF24),
                    size: 32,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SDG 6 Sanitation Contributor',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your feedback promotes community dignity and accountable sanitation management.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Menu Shortcuts
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.assignment_outlined,
                    title: 'My Submitted Reports',
                    subtitle: 'Track status of your complaints & reviews',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyFeedbackScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppTheme.dividerColor),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About CleanSpot',
                    subtitle: 'Version ${AppConstants.appVersion} • Target 6.2 Aligned',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: AppConstants.appName,
                        applicationVersion: AppConstants.appVersion,
                        applicationIcon: const Icon(
                          Icons.cleaning_services_rounded,
                          size: 36,
                          color: AppTheme.primaryColor,
                        ),
                        children: const [
                          Text(
                            'CleanSpot is a civic sanitation feedback system connecting citizens with public restroom hygiene monitoring and administrative response pipelines.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppTheme.dividerColor),
                  _buildMenuItem(
                    icon: Icons.cloud_done_outlined,
                    title: 'Supabase Cloud Backend',
                    subtitle: SupabaseConfig.isConfigured
                        ? 'Connected • Live Auth & Storage'
                        : 'Unconfigured • Sample Verified Data Active',
                    iconColor: SupabaseConfig.isConfigured
                        ? const Color(0xFF10B981)
                        : AppTheme.statusPending,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            SupabaseConfig.isConfigured
                                ? 'Supabase connected at: ${SupabaseConfig.supabaseUrl}'
                                : 'Configure URL and Anon Key in lib/config/supabase_config.dart',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout_rounded,
                    color: AppTheme.statusRejected, size: 20),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: AppTheme.statusRejected,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFECACA), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = AppTheme.primaryColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppTheme.textMuted,
      ),
      onTap: onTap,
    );
  }
}
