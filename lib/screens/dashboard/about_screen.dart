import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../theme/app_colors.dart';
import '../../widgets/swiss.dart';

/// About the app, its makers and RoboVITics (the club behind it).
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = '${info.version}+${info.buildNumber}');
    } catch (_) {
      // Version is cosmetic; leave it blank rather than show an error.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: swissAppBar(context, 'About'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          children: [
            // The app.
            Row(
              children: [
                Image.asset('assets/icon/app_icon_tile.png', width: 56, height: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Digital Inventory',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (_version.isNotEmpty)
                        Text('Version $_version', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Keep your bills, warranty cards and expiry dates in one place. Add a product, '
              'attach its invoice, and get a reminder before the warranty runs out. It works '
              'offline and syncs when you are back online.',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5),
            ),

            const SizedBox(height: 32),
            _heading('Made by'),
            _person('Preethi S', 'VIT student · RoboVITics'),
            _person('Pragdeeshraj B', 'VIT student · RoboVITics'),

            const SizedBox(height: 32),
            _heading('The club'),
            // Black block so the white wordmark reads on both themes.
            Container(
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Image.asset(
                'assets/images/robovitics_logo.png',
                fit: BoxFit.contain,
                height: 56,
                errorBuilder: (context, error, stack) => const Text(
                  'roboVITics',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'RoboVITics is the robotics club of VIT, run by students. Members learn by '
              'building: robots, electronics and software projects, supported by workshops '
              'and team work, and they take what they make to competitions and showcases. '
              'Digital Inventory was built by two of its members.',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heading(String text) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.rule, width: 0.8))),
      child: Text(text, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800)),
    );
  }

  Widget _person(String name, String role) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.ruleSoft, width: 0.8))),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3),
            ),
          ),
          Text(role, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
