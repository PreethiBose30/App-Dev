import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/product.dart';

/// Schedules/cancels the on-device "warranty expiring soon" reminder for
/// each product. One notification per asset, keyed by a stable id derived
/// from its Mongo ObjectId so the same reminder can be found again later
/// (to cancel or reschedule it) without keeping a separate id mapping.
class NotificationService {
  static const int daysBefore = 7;

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized || kIsWeb) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  // Dart's String.hashCode isn't guaranteed stable across runs, but
  // cancelling/rescheduling the same reminder later requires the exact same
  // notification id every time -- so this uses a simple deterministic hash
  // instead (32-bit range, since notification ids are plain ints).
  static int _idFor(String assetId) {
    int hash = 7;
    for (final unit in assetId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  /// Schedules (or cancels) the reminder for one product based on its
  /// current `reminderEnabled` flag and `warrantyExpiry`. Safe to call
  /// every time a product is created, edited, or re-fetched -- it always
  /// leaves exactly the right state instead of accumulating duplicates.
  static Future<void> syncReminder(Product product) async {
    if (kIsWeb || product.id == null) return;
    await init();

    final id = _idFor(product.id!);
    final expiry = product.warrantyExpiry;

    if (!product.reminderEnabled || expiry == null || expiry.isBefore(DateTime.now())) {
      await _plugin.cancel(id);
      return;
    }

    final idealFireDate = expiry.subtract(const Duration(days: daysBefore));
    // If the ideal "N days before" moment already passed but the warranty
    // itself hasn't expired yet, fire almost immediately instead of
    // silently never notifying at all.
    final fireDate = idealFireDate.isAfter(DateTime.now()) ? idealFireDate : DateTime.now().add(const Duration(minutes: 1));

    await _plugin.zonedSchedule(
      id,
      'Warranty expiring soon',
      '${product.name} warranty expires on ${_formatDate(expiry)}.',
      tz.TZDateTime.from(fireDate, tz.UTC),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'warranty_reminders',
          'Warranty Reminders',
          channelDescription: 'Reminders for upcoming warranty expirations',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelReminder(String assetId) async {
    if (kIsWeb) return;
    await init();
    await _plugin.cancel(_idFor(assetId));
  }

  /// Re-syncs every product's reminder in one pass. Called after the vault
  /// list loads so reminders stay correct even on a fresh install or a
  /// second device where nothing has been scheduled locally yet.
  static Future<void> syncAll(List<Product> products) async {
    if (kIsWeb) return;
    await init();
    for (final product in products) {
      await syncReminder(product);
    }
  }

  static String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
