class Settings {
  final String lang; // ar | en | fr
  final bool dark;
  final bool notificationsOn;
  final String sound; // fajr_adhan | makkah_adhan | madinah_adhan
  final String reminderMsg;
  final List<int> alertMinutes; // minutes since midnight

  const Settings({
    this.lang = 'ar',
    this.dark = false,
    this.notificationsOn = true,
    this.sound = 'fajr_adhan',
    this.reminderMsg = '',
    this.alertMinutes = const [],
  });

  Settings copyWith({String? lang, bool? dark, bool? notificationsOn, String? sound, String? reminderMsg, List<int>? alertMinutes}) =>
      Settings(
        lang: lang ?? this.lang,
        dark: dark ?? this.dark,
        notificationsOn: notificationsOn ?? this.notificationsOn,
        sound: sound ?? this.sound,
        reminderMsg: reminderMsg ?? this.reminderMsg,
        alertMinutes: alertMinutes ?? this.alertMinutes,
      );

  Map<String, dynamic> toJson() => {
        'lang': lang, 'dark': dark, 'notificationsOn': notificationsOn,
        'sound': sound, 'reminderMsg': reminderMsg, 'alertMinutes': alertMinutes,
      };

  factory Settings.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const Settings();
    try {
      final lang = j['lang'] as String? ?? 'ar';
      return Settings(
        lang: ['ar', 'en', 'fr'].contains(lang) ? lang : 'ar',
        dark: j['dark'] as bool? ?? false,
        notificationsOn: j['notificationsOn'] as bool? ?? true,
        sound: j['sound'] as String? ?? 'fajr_adhan',
        reminderMsg: j['reminderMsg'] as String? ?? '',
        alertMinutes: ((j['alertMinutes'] as List?) ?? []).map((e) => (e as num).toInt()).toList(),
      );
    } catch (_) {
      return const Settings();
    }
  }
}

class AlarmItem {
  final int id; // small positive int (< 200000)
  final int minutes; // minutes since midnight
  final bool enabled;
  final List<int> days; // 0 = Sunday ... 6 = Saturday (empty = one-time)
  final String tone;
  final double volume; // 0.1 .. 1.0
  final int autoStopMinutes; // 5 or 10: stops by itself if the user does not swipe
  final int repeatMinutes; // 0 = no repeat, else 5 / 10 / 15 (rings again up to 3 times)
  final bool vibrate; // off by default

  const AlarmItem({required this.id, this.minutes = 285, this.enabled = true, this.days = const [], this.tone = 'fajr_adhan', this.volume = 0.9, this.autoStopMinutes = 10, this.repeatMinutes = 0, this.vibrate = false});

  AlarmItem copyWith({int? minutes, bool? enabled, List<int>? days, String? tone, double? volume, int? autoStopMinutes, int? repeatMinutes, bool? vibrate}) => AlarmItem(
        id: id,
        minutes: minutes ?? this.minutes,
        enabled: enabled ?? this.enabled,
        days: days ?? this.days,
        tone: tone ?? this.tone,
        volume: volume ?? this.volume,
        autoStopMinutes: autoStopMinutes ?? this.autoStopMinutes,
        repeatMinutes: repeatMinutes ?? this.repeatMinutes,
        vibrate: vibrate ?? this.vibrate,
      );

  Map<String, dynamic> toJson() => {'id': id, 'minutes': minutes, 'enabled': enabled, 'days': days, 'tone': tone, 'volume': volume, 'autoStopMinutes': autoStopMinutes, 'repeatMinutes': repeatMinutes, 'vibrate': vibrate};

  static AlarmItem? tryFrom(dynamic j) {
    try {
      final m = j as Map;
      return AlarmItem(
        id: (m['id'] as num).toInt(),
        minutes: (m['minutes'] as num).toInt() % 1440,
        enabled: m['enabled'] as bool? ?? true,
        days: ((m['days'] as List?) ?? []).map((e) => (e as num).toInt()).where((d) => d >= 0 && d <= 6).toList(),
        tone: m['tone'] as String? ?? 'fajr_adhan',
        volume: ((m['volume'] as num?) ?? 0.9).toDouble().clamp(0.1, 1.0).toDouble(),
        autoStopMinutes: [5, 10].contains((m['autoStopMinutes'] as num?)?.toInt()) ? (m['autoStopMinutes'] as num).toInt() : 10,
        repeatMinutes: [0, 5, 10, 15].contains((m['repeatMinutes'] as num?)?.toInt()) ? (m['repeatMinutes'] as num).toInt() : 0,
        vibrate: m['vibrate'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }
}

class DaysState {
  final int count;
  final int selected;
  final Map<String, Map<String, dynamic>> entries; // "1" -> {quote, note, done}

  const DaysState({this.count = 1, this.selected = 1, this.entries = const {}});

  Map<String, dynamic> get current => entries['$selected'] ?? const {};

  /// Consecutive completed days, ending at the latest decided day.
  int get streak {
    var i = count;
    if (entries['$i']?['done'] == null) i--;
    var n = 0;
    while (i >= 1 && entries['$i']?['done'] == true) {
      n++;
      i--;
    }
    return n;
  }

  DaysState copyWith({int? count, int? selected, Map<String, Map<String, dynamic>>? entries}) =>
      DaysState(count: count ?? this.count, selected: selected ?? this.selected, entries: entries ?? this.entries);

  Map<String, dynamic> toJson() => {'count': count, 'selected': selected, 'entries': entries};

  factory DaysState.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const DaysState();
    try {
      final raw = (j['entries'] as Map?) ?? {};
      return DaysState(
        count: ((j['count'] as num?) ?? 1).toInt().clamp(1, 10000),
        selected: ((j['selected'] as num?) ?? 1).toInt().clamp(1, 10000),
        entries: raw.map((k, v) => MapEntry(k as String, Map<String, dynamic>.from(v as Map))),
      );
    } catch (_) {
      return const DaysState();
    }
  }
}
