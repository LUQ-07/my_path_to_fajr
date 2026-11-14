import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// AES-256 encrypted Hive box. The key lives in the Android Keystore / iOS Keychain
/// (flutter_secure_storage). Nothing is ever stored in plain text.
class SecureStore {
  static Box? _box;
  static const _keyName = 'fajr_hive_key_v1';

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      const storage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
      var k = await storage.read(key: _keyName);
      if (k == null) {
        k = base64UrlEncode(Hive.generateSecureKey());
        await storage.write(key: _keyName, value: k);
      }
      _box = await Hive.openBox('fajr_secure',
          encryptionCipher: HiveAesCipher(base64Url.decode(k)));
    } catch (e) {
      debugPrint('SecureStore init failed: $e');
    }
  }

  static T? read<T>(String key) {
    try {
      final v = _box?.get(key);
      if (v == null) return null;
      return jsonDecode(v as String) as T;
    } catch (e) {
      debugPrint('SecureStore read($key) failed: $e');
      return null;
    }
  }

  static Future<void> write(String key, Object value) async {
    try {
      await _box?.put(key, jsonEncode(value));
    } catch (e) {
      debugPrint('SecureStore write($key) failed: $e');
    }
  }
}
