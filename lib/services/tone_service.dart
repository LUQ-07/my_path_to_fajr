import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../core/security/sanitizer.dart';
import '../core/security/secure_store.dart';
import '../l10n/app_strings.dart';

class CustomTone {
  final String id, name, path;
  const CustomTone(this.id, this.name, this.path);
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'path': path};
}

/// Built-in tones live in assets/audio. Custom tones are audio files the user picks
/// from the phone; they are copied into the app's private folder.
/// Custom tones are used by alarms and previews. Notification sounds on Android are
/// fixed per channel, so they keep using res/raw/fajr_adhan.mp3.
class ToneService {
  static const builtin = ['fajr_adhan', 'makkah_adhan', 'madinah_adhan'];
  static const addMarker = '__add__';
  static const maxBytes = 15 * 1024 * 1024;

  static List<CustomTone> load() {
    final raw = SecureStore.read<List<dynamic>>('custom_tones') ?? [];
    final out = <CustomTone>[];
    for (final e in raw) {
      try {
        final m = e as Map;
        out.add(CustomTone(m['id'] as String, m['name'] as String, m['path'] as String));
      } catch (_) {}
    }
    return out;
  }

  static Future<CustomTone?> pickAndSave() async {
    try {
      final r = await FilePicker.platform.pickFiles(type: FileType.audio);
      final f = r?.files.single;
      final src = f?.path;
      if (f == null || src == null) return null;
      if (await File(src).length() > maxBytes) return null;
      final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/tones');
      await dir.create(recursive: true);
      final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
      final ext = src.contains('.') ? src.split('.').last.toLowerCase() : 'mp3';
      final dest = '${dir.path}/$id.$ext';
      await File(src).copy(dest);
      final base = f.name.contains('.') ? f.name.substring(0, f.name.lastIndexOf('.')) : f.name;
      final tone = CustomTone(id, Sanitizer.clean(base, max: 40), dest);
      await SecureStore.write('custom_tones', [...load(), tone].map((e) => e.toJson()).toList());
      return tone;
    } catch (e) {
      debugPrint('pickAndSave failed: $e');
      return null;
    }
  }

  static Future<void> remove(String id) async {
    try {
      final list = load();
      for (final t in list.where((t) => t.id == id)) {
        final f = File(t.path);
        if (await f.exists()) await f.delete();
      }
      await SecureStore.write('custom_tones', list.where((t) => t.id != id).map((e) => e.toJson()).toList());
    } catch (e) {
      debugPrint('remove tone failed: $e');
    }
  }

  static CustomTone? _custom(String id) {
    for (final t in load()) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Path used by the alarm package (asset path or absolute file path).
  static String audioPath(String id) {
    final c = _custom(id);
    if (c != null && File(c.path).existsSync()) return c.path;
    final safe = builtin.contains(id) ? id : 'fajr_adhan';
    return 'assets/audio/$safe.mp3';
  }

  static Source source(String id) {
    final c = _custom(id);
    if (c != null && File(c.path).existsSync()) return DeviceFileSource(c.path);
    final safe = builtin.contains(id) ? id : 'fajr_adhan';
    return AssetSource('audio/$safe.mp3');
  }

  static String label(AppStrings s, String id, List<CustomTone> customs) {
    if (builtin.contains(id)) return s.t('tone_$id');
    for (final t in customs) {
      if (t.id == id) return t.name;
    }
    return s.t('tone_fajr_adhan');
  }
}
