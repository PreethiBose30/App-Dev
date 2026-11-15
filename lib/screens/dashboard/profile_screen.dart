import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/swiss.dart';
import '../../theme/theme_controller.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'about_screen.dart';
import 'appearance_settings_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with ThemeAwareState {
  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Log out?', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('LOG OUT', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthService.logout();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _editProfile() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
    if (mounted) setState(() {}); // Pick up the name AuthService just refreshed.
  }

  void _showAbout() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.cachedUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: swissAppBar(context, 'Profile'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text(
              user?.name ?? 'Unknown user',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 40, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -1.8),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Flexible(
                  child: Text(user?.email ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ),
                if (user?.isAdmin == true) ...[
                  const SizedBox(width: 10),
                  Text('Admin', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w800)),
                ],
              ],
            ),
            const SizedBox(height: 32),
            const SwissLabel('Account'),
            _option('Edit profile', 'Change your name', _editProfile),
            _option(
              'Notifications',
              'Reminder lead time and permission',
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),
            ),
            _option(
              'Appearance',
              'Light, dark or system',
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AppearanceSettingsScreen())),
            ),
            const SizedBox(height: 28),
            const SwissLabel('About'),
            _option('About', 'The app, its makers and RoboVITics', _showAbout),
            const SizedBox(height: 36),
            SwissButton('Log out', outlined: true, onPressed: () => _logout(context)),
          ],
        ),
      ),
    );
  }

  Widget _option(String title, String subtitle, VoidCallback onTap) {
    return SwissRow(
      soft: true,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      trailing: Icon(Icons.arrow_forward, color: AppColors.textPrimary, size: 18),
    );
  }
}
