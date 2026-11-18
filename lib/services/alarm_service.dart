import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';

import '../core/security/secure_store.dart';
import '../domain/models.dart';
import 'tone_service.dart';
import '../core/constants/fajr_quotes.dart';
import '../l10n/app_strings.dart';

/// Alarms use the `alarm` package (foreground service + full-screen intent) so they
/// ring even when the app is closed or the phone is locked.
/// The package fires one-shot alarms, so repeating alarms are re-armed whenever the
/// app opens, an alarm rings, or the list changes.
class AlarmService {
  static const tones = ['fajr_adhan', 'makkah_adhan', 'madinah_adhan'];

  static Future<void> init() async {
    try {
      await Alarm.init();
    } catch (e) {
      debugPrint('Alarm init failed: $e');
    }
  }

  static List<AlarmItem> loadFromStore() {
    final raw = SecureStore.read<List<dynamic>>('alarms') ?? [];
    return raw.map(AlarmItem.tryFrom).whereType<AlarmItem>().toList();
  }

  static DateTime _next(int minutes, int? weekdaySun0) {
    final now = DateTime.now();
    for (var off = 0; off <= 7; off++) {
      final d = DateTime(now.year, now.month, now.day + off, minutes ~/ 60, minutes % 60);
      if (d.isAfter(now) && (weekdaySun0 == null || d.weekday % 7 == weekdaySun0)) return d;
    }
    return now.add(const Duration(days: 1));
  }

  static Future<void> cancelFor(int alarmId) async {
    for (var d = 0; d <= 7; d++) {
      try {
        await Alarm.stop(alarmId * 10 + d);
      } catch (e) {
        debugPrint('Alarm.stop failed: $e');
      }
    }
  }

  static Future<void> rescheduleAll(List<AlarmItem> items) async {
    final lang = Settings.fromJson(SecureStore.read<Map<String, dynamic>>('settings')).lang;
    final strings = AppStrings(lang);
    final quote = fajrQuotes[DateTime.now().day % fajrQuotes.length].text(lang);
    for (final a in items) {
      await cancelFor(a.id);
      if (!a.enabled) continue;
      final targets = a.days.isEmpty ? <int?>[null] : a.days.cast<int?>();
      for (final day in targets) {
        try {
          await Alarm.set(
            alarmSettings: AlarmSettings(
              id: a.id * 10 + (day ?? 7),
              dateTime: _next(a.minutes, day),
              assetAudioPath: ToneService.audioPath(a.tone),
              loopAudio: true,
              vibrate: true,
              volume: a.volume,
              fadeDuration: 3.0,
              androidFullScreenIntent: true,
              notificationSettings: NotificationSettings(
                title: strings.t('notifTitle'),
                body: quote,
                stopButton: 'Stop',
              ),
            ),
          );
        } catch (e) {
          debugPrint('Alarm.set failed: $e');
        }
      }
    }
  }
}
