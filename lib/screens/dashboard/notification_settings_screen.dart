import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text('NOTIFICATIONS', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
          children: [
            if (_permissionGranted == false)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_off_outlined, color: Colors.orangeAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Notifications are turned off for this app at the system level. '
                        'Enable them in Settings > Apps > Digital Inventory > Notifications to receive warranty reminders.',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
              child: SwitchListTile(
                value: _remindersEnabled,
                onChanged: _onToggleReminders,
                activeColor: AppColors.accent,
                title: Text('WARRANTY EXPIRY REMINDERS', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text('Get notified before a warranty expires', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'REMIND ME',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: _remindersEnabled ? 1 : 0.4,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: NotificationService.allowedLeadTimes.map((days) {
                  final selected = days == _daysBefore;
                  return ChoiceChip(
                    label: Text('$days day${days == 1 ? '' : 's'} before'),
                    selected: selected,
                    onSelected: _remindersEnabled ? (_) => _onChangeDaysBefore(days) : null,
                    selectedColor: AppColors.accent,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.onAccent : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_isResyncing) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent)),
                  const SizedBox(width: 10),
                  Text('Updating reminders...', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
