import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/swiss.dart';
import '../../theme/theme_controller.dart';
import '../../services/api_client.dart';
import '../../services/asset_repository.dart';
import '../../services/notification_service.dart';

/// Warranty-reminder preferences: master on/off, lead time, and the current
/// OS notification permission status. Any change here re-syncs every
/// product's scheduled reminder immediately (not just on the next
/// home-screen load).
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> with ThemeAwareState {
  late bool _remindersEnabled = NotificationService.remindersEnabled;
  late int _daysBefore = NotificationService.daysBefore;
  bool? _permissionGranted;
  bool _isResyncing = false;

  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    final granted = await NotificationService.permissionGranted();
    if (!mounted) return;
    setState(() => _permissionGranted = granted);
  }

  Future<void> _resyncAll() async {
    setState(() => _isResyncing = true);
    try {
      final products = await AssetRepository.getAssets();
      await NotificationService.syncAll(products);
    } on ApiException {
      // Settings are already saved; a resync failure here just means it'll
      // catch up next time the vault list loads.
    } finally {
      if (mounted) setState(() => _isResyncing = false);
    }
  }

  Future<void> _onToggleReminders(bool value) async {
    if (value) {
      final granted = await NotificationService.requestPermission();
      if (!mounted) return;
      setState(() => _permissionGranted = granted);
    }

    setState(() => _remindersEnabled = value);
    await NotificationService.setRemindersEnabled(value);
    await _resyncAll();
  }

  Future<void> _onChangeDaysBefore(int value) async {
    setState(() => _daysBefore = value);
    await NotificationService.setDaysBefore(value);
    await _resyncAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: swissAppBar(context, 'Notifications'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          children: [
            Text(
              'Warranty reminders',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 34, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -1.6),
            ),
            const SizedBox(height: 20),
            if (_permissionGranted == false)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(border: Border(left: BorderSide(color: AppColors.accent, width: 3))),
                child: Text(
                  'Notifications are turned off for this app in system settings. Turn them on in '
                  'Settings > Apps > Digital Inventory > Notifications to receive warranty reminders.',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4),
                ),
              ),
            const SwissLabel('Reminders'),
            SwitchListTile(
              value: _remindersEnabled,
              onChanged: _onToggleReminders,
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Warranty expiry reminders',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Get notified at 9:00 AM before a warranty expires',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
            const SwissLabel('Remind me'),
            Opacity(
              opacity: _remindersEnabled ? 1 : 0.4,
              child: Column(
                children: [
                  for (final days in NotificationService.allowedLeadTimes)
                    SwissRow(
                      soft: true,
                      title: '$days ${days == 1 ? 'day' : 'days'} before',
                      onTap: _remindersEnabled ? () => _onChangeDaysBefore(days) : null,
                      trailing: days == _daysBefore ? Icon(Icons.check, color: AppColors.accent, size: 20) : null,
                    ),
                ],
              ),
            ),
            if (_isResyncing) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent)),
                  const SizedBox(width: 10),
                  Text('Updating reminders...', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
