import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        title: const Text(
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

                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Your Name',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          'your.email@example.com',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
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
                onTap: () {},
              ),

              _ProfileOption(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Manage your reminder preferences',
                onTap: () {},
              ),

              _ProfileOption(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'Customize your app experience',
                onTap: () {},
              ),

              const SizedBox(height: 24),

              const Text(
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
                onTap: () {},
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,

                child: OutlinedButton.icon(
                  onPressed: () {},

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

        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Text(
        subtitle,

        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      ),

      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),

      onTap: onTap,
    );
  }
}