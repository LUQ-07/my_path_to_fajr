import 'dart:math' as math;

import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/fajr_quotes.dart';
import '../core/security/secure_store.dart';
import '../domain/models.dart';
import '../l10n/app_strings.dart';
import 'tone_service.dart';

/// Alarms use the `alarm` package (foreground service + full-screen intent) so they
/// ring even when the app is closed or the phone is locked.
///
/// Every alarm instance is scheduled together with up to [maxRepeats] "repeat" alarms
/// (every 5/10/15 minutes) so they work even if the app is closed. Swiping to stop cancels
/// the pending repeats. The package fires one-shot alarms, so the next occurrence is armed
/// whenever the app opens or an alarm is stopped.
class AlarmService {
  static const tones = ['fajr_adhan', 'makkah_adhan', 'madinah_adhan'];
  static const maxRepeats = 3;
  static const _repeatBase = 1000000000;

  // id layout: base = alarmId*10 + weekday(0..6) or 7 (one time); repeat k = 1e9 + base*10 + k
  static int repeatId(int baseId, int k) => _repeatBase + baseId * 10 + k;
  static bool isRepeat(int id) => id >= _repeatBase;
  static int baseIdOf(int id) => isRepeat(id) ? (id - _repeatBase) ~/ 10 : id;
  static int repeatIndexOf(int id) => isRepeat(id) ? (id - _repeatBase) % 10 : 0;
  static int alarmIdOf(int id) => baseIdOf(id) ~/ 10;

  /// How long one ring lasts before it stops by itself.
  static int ringMinutes(AlarmItem? a) {
    if (a == null) return 10;
    return a.repeatMinutes > 0 ? math.min(a.autoStopMinutes, a.repeatMinutes) : a.autoStopMinutes;
  }

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
      final base = alarmId * 10 + d;
      try {
        await Alarm.stop(base);
        for (var k = 1; k <= maxRepeats; k++) {
          await Alarm.stop(repeatId(base, k));
        }
      } catch (e) {
        debugPrint('Alarm.stop failed: $e');
      }
    }
  }

  static Future<void> _set(int id, DateTime when, AlarmItem a, AppStrings strings, String quote) async {
    try {
      await Alarm.set(
        alarmSettings: AlarmSettings(
          id: id,
          dateTime: when,
          assetAudioPath: ToneService.audioPath(a.tone),
          // Tones picked from the phone loop until the stop time; adhans play once.
          loopAudio: a.tone.startsWith('custom_'),
          vibrate: a.vibrate,
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

  static Future<void> rescheduleAll(List<AlarmItem> items) async {
    final lang = Settings.fromJson(SecureStore.read<Map<String, dynamic>>('settings')).lang;
    final strings = AppStrings(lang);
    final quote = fajrQuotes[DateTime.now().day % fajrQuotes.length].text(lang);
    for (final a in items) {
      await cancelFor(a.id);
      if (!a.enabled) continue;
      final targets = a.days.isEmpty ? <int?>[null] : a.days.cast<int?>();
      for (final day in targets) {
        final base = a.id * 10 + (day ?? 7);
        final when = _next(a.minutes, day);
        await _set(base, when, a, strings, quote);
        if (a.repeatMinutes > 0) {
          for (var k = 1; k <= maxRepeats; k++) {
            await _set(repeatId(base, k), when.add(Duration(minutes: a.repeatMinutes * k)), a, strings, quote);
          }
        }
      }
    }
  }
}
