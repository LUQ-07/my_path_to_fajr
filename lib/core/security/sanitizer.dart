/// Strict input sanitization for every user-provided text field.
class Sanitizer {
  static final _ctrl = RegExp(
      r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F\u200E\u200F\u202A-\u202E\u2066-\u2069]');
  static final _danger = RegExp(r'[<>{}\\$`]');

  static String clean(String input, {int max = 200, bool multiline = false}) {
    var s = input.replaceAll(_ctrl, '').replaceAll(_danger, '');
    if (!multiline) s = s.replaceAll(RegExp(r'\s+'), ' ');
    s = s.trim();
    final runes = s.runes.toList();
    if (runes.length > max) s = String.fromCharCodes(runes.take(max));
    return s;
  }
}
