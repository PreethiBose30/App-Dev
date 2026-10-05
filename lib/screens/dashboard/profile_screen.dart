import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
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
            child: const Text('LOG OUT', style: TextStyle(color: Colors.redAccent)),
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

  Future<void> _showAbout() async {
    String version = '';
    try {
      final info = await PackageInfo.fromPlatform();
      version = '${info.version}+${info.buildNumber}';
    } catch (_) {
      version = 'unavailable';
    }
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Digital Inventory', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Version $version', style: TextStyle(color: AppColors.textSecondary)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.cachedUser;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        title: Text(
          'PROFILE',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),

                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,

                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        Icons.person_outline,
                        color: AppColors.onAccent,
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          user?.name ?? 'Unknown user',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),

                        if (user?.isAdmin == true) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ADMIN',
                              style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'ACCOUNT',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              _ProfileOption(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: _editProfile,
              ),

              _ProfileOption(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Manage your reminder preferences',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),
              ),

              _ProfileOption(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'Customize your app experience',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AppearanceSettingsScreen())),
              ),

              const SizedBox(height: 24),

              Text(
                'ABOUT',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              _ProfileOption(
                icon: Icons.info_outline,
                title: 'About Digital Inventory',
                subtitle: 'App information and version',
                onTap: _showAbout,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,

                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),

                  icon: const Icon(
                    Icons.logout,
                    size: 18,
                  ),

                  label: const Text('LOG OUT'),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,

                    side: BorderSide(
                      color: Colors.redAccent.withOpacity(0.4),
                    ),

                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 6,
      ),

      leading: Container(
        padding: const EdgeInsets.all(11),

        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(13),
        ),

        child: Icon(
          icon,
          color: AppColors.primary,
          size: 21,
        ),
      ),

      title: Text(
        title,

        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Text(
        subtitle,

        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      ),

      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),

      onTap: onTap,
    );
  }
}
