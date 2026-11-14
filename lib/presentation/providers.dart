import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/security/secure_store.dart';
import '../domain/models.dart';
import '../services/alarm_service.dart';
import '../services/notification_service.dart';
import '../services/tone_service.dart';

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
    return _save([...state, AlarmItem(id: id, tone: ref.read(settingsProvider).sound)]);
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
