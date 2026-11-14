import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/constants/fajr_quotes.dart';
import '../domain/models.dart';
import '../l10n/app_strings.dart';

/// Rolling-window scheduler. iOS allows ~64 pending local notifications and Android
/// ~500, so we queue at most [maxQueue] upcoming reminders and refresh the queue every
/// time the app opens / settings change / the device reboots (boot receiver re-arms them).
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const maxQueue = 60;
  static const _baseId = 1000;
  static int lastScheduled = 0;

  static Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
      const init = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _plugin.initialize(init);
    } catch (e) {
      debugPrint('Notification init failed: $e');
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      var ok = true;
      if (android != null) {
        ok = await android.requestNotificationsPermission() ?? false;
        await android.requestExactAlarmsPermission();
      }
      if (ios != null) {
        ok = await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
      }
      return ok;
    } catch (e) {
      debugPrint('Permission request failed: $e');
      return false;
    }
  }

  static Future<int> reschedule(Settings s) async {
    var scheduled = 0;
    try {
      for (var i = 0; i < maxQueue; i++) {
        await _plugin.cancel(_baseId + i);
      }
      if (!s.notificationsOn || s.alertMinutes.isEmpty) {
        lastScheduled = 0;
        return 0;
      }
      final strings = AppStrings(s.lang);
      final base = s.reminderMsg.isEmpty ? strings.t('defaultMsg') : s.reminderMsg;
      final times = [...s.alertMinutes]..sort();
      final now = tz.TZDateTime.now(tz.local);
      final epochDay = DateTime.utc(now.year, now.month, now.day).difference(DateTime.utc(2024)).inDays;

      outer:
      for (var d = 0; d < 60; d++) {
        for (var t = 0; t < times.length; t++) {
          if (scheduled >= maxQueue) break outer;
          final m = times[t];
          final when = tz.TZDateTime(tz.local, now.year, now.month, now.day + d, m ~/ 60, m % 60);
          if (!when.isAfter(now)) continue;
          final q = fajrQuotes[((epochDay + d) * times.length + t) % fajrQuotes.length];
          final body = '$base\n${q.text(s.lang)}';
          await _plugin.zonedSchedule(
            _baseId + scheduled,
            strings.t('notifTitle'),
            body,
            when,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'fajr_reminders_v1',
                'Fajr reminders',
                importance: Importance.max,
                priority: Priority.high,
                styleInformation: BigTextStyleInformation(body),
                sound: const RawResourceAndroidNotificationSound('fajr_adhan'),
              ),
              iOS: const DarwinNotificationDetails(presentSound: true),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          );
          scheduled++;
        }
      }
    } catch (e) {
      debugPrint('Reschedule failed: $e');
    }
    lastScheduled = scheduled;
    return scheduled;
  }
}
