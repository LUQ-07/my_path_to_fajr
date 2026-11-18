import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/security/secure_store.dart';
import '../domain/models.dart';
import '../services/alarm_service.dart';
import '../services/notification_service.dart';
import '../services/tone_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() => Settings.fromJson(SecureStore.read<Map<String, dynamic>>('settings'));

  Future<void> update(Settings s, {bool reschedule = false}) async {
    state = s;
    await SecureStore.write('settings', s.toJson());
    if (reschedule) await NotificationService.reschedule(s);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

class DaysNotifier extends Notifier<DaysState> {
  @override
  DaysState build() => DaysState.fromJson(SecureStore.read<Map<String, dynamic>>('days'));

  Future<void> _save(DaysState s) async {
    state = s;
    await SecureStore.write('days', s.toJson());
  }

  Future<void> addDay() => _save(state.copyWith(count: state.count + 1, selected: state.count + 1));

  /// Deletes a day and renumbers the following ones (day 4 becomes 3, and so on).
  Future<void> deleteDay(int day) {
    final e = <String, Map<String, dynamic>>{};
    state.entries.forEach((k, v) {
      final n = int.tryParse(k);
      if (n == null || n == day) return;
      e['${n > day ? n - 1 : n}'] = v;
    });
    final newCount = state.count > 1 ? state.count - 1 : 1;
    var sel = state.selected;
    if (sel > day) sel -= 1;
    if (sel > newCount) sel = newCount;
    if (sel < 1) sel = 1;
    return _save(DaysState(count: newCount, selected: sel, entries: e));
  }

  /// "Start over": clears all days and their notes.
  Future<void> reset() => _save(const DaysState());
  Future<void> select(int d) => _save(state.copyWith(selected: d));

  Future<void> _patch(String key, Object? value) {
    final e = {...state.entries};
    e['${state.selected}'] = {...(e['${state.selected}'] ?? {}), key: value};
    return _save(state.copyWith(entries: e));
  }

  Future<void> setQuote(String q) => _patch('quote', q);
  Future<void> setNote(String n) => _patch('note', n);
  Future<void> setDone(bool v) => _patch('done', v);
}

final daysProvider = NotifierProvider<DaysNotifier, DaysState>(DaysNotifier.new);

class AlarmsNotifier extends Notifier<List<AlarmItem>> {
  @override
  List<AlarmItem> build() => AlarmService.loadFromStore();

  Future<void> _save(List<AlarmItem> l) async {
    state = l;
    await SecureStore.write('alarms', l.map((e) => e.toJson()).toList());
    await AlarmService.rescheduleAll(l);
  }

  Future<void> add() {
    final id = (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 100000 + 1;
    return _save([...state, AlarmItem(id: id)]);
  }

  Future<void> replace(AlarmItem a) => _save([for (final x in state) x.id == a.id ? a : x]);

  Future<void> remove(AlarmItem a) async {
    await AlarmService.cancelFor(a.id);
    await _save(state.where((x) => x.id != a.id).toList());
  }
}

final alarmsProvider = NotifierProvider<AlarmsNotifier, List<AlarmItem>>(AlarmsNotifier.new);

class CustomTonesNotifier extends Notifier<List<CustomTone>> {
  @override
  List<CustomTone> build() => ToneService.load();

  /// Lets the user pick an audio file from the phone. Returns the new tone or null.
  Future<CustomTone?> pick() async {
    final t = await ToneService.pickAndSave();
    state = ToneService.load();
    return t;
  }

  Future<void> remove(String id) async {
    await ToneService.remove(id);
    state = ToneService.load();
  }
}

final customTonesProvider = NotifierProvider<CustomTonesNotifier, List<CustomTone>>(CustomTonesNotifier.new);

/// Path of the monthly-session image the user chose (copied into the app's private folder).
/// The image is downscaled by the picker, and a result lost because Android killed the app
/// while the gallery was open (low RAM phones) is recovered on the next launch.
class MonthlyImageNotifier extends Notifier<String?> {
  final ImagePicker _picker = ImagePicker();

  @override
  String? build() {
    final path = SecureStore.read<String>('monthly_image');
    if (path != null && path.isNotEmpty && File(path).existsSync()) return path;
    return null;
  }

  Future<void> pick() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (x == null) return;
      await _save(x.path);
    } catch (e) {
      debugPrint('monthly image pick failed: $e');
    }
  }

  /// Call once at startup: recovers an image picked just before the process was killed.
  Future<void> recoverLost() async {
    if (kIsWeb) return;
    try {
      final r = await _picker.retrieveLostData();
      if (r.isEmpty) return;
      final f = r.file ?? ((r.files != null && r.files!.isNotEmpty) ? r.files!.first : null);
      if (f != null) await _save(f.path);
    } catch (e) {
      debugPrint('recoverLost failed: $e');
    }
  }

  Future<void> _save(String src) async {
    final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/monthly');
    await dir.create(recursive: true);
    final ext = src.contains('.') ? src.split('.').last.toLowerCase() : 'jpg';
    final dest = '${dir.path}/monthly_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await File(src).copy(dest);
    final old = state;
    await SecureStore.write('monthly_image', dest);
    state = dest;
    if (old != null && old != dest && File(old).existsSync()) await File(old).delete();
  }

  Future<void> remove() async {
    try {
      final old = state;
      if (old != null && File(old).existsSync()) await File(old).delete();
      await SecureStore.write('monthly_image', '');
      state = null;
    } catch (e) {
      debugPrint('monthly image remove failed: $e');
    }
  }
}

final monthlyImageProvider = NotifierProvider<MonthlyImageNotifier, String?>(MonthlyImageNotifier.new);
