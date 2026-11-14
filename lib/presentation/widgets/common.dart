import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';

class CardBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const CardBox({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: padding,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: child,
      );
}

class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool gold;
  final Color? color;
  final IconData? icon;
  const PillButton({super.key, required this.label, required this.onTap, this.filled = false, this.gold = false, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = filled ? (color ?? (gold ? AppColors.gold : AppColors.navy)) : Colors.transparent;
    final fg = filled ? Colors.white : cs.onSurface;
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color ?? AppColors.gold, width: 1.4),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 6)],
          Flexible(child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: fg, fontWeight: FontWeight.w600))),
        ]),
      ),
    );
  }
}

/// Text input dialog with proper controller disposal and length limit.
class TextInputDialog extends StatefulWidget {
  final String title, hint, initial;
  final int maxLength;
  final bool multiline;
  const TextInputDialog({super.key, required this.title, required this.hint, this.initial = '', this.maxLength = 200, this.multiline = false});

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _c,
        maxLength: widget.maxLength,
        maxLines: widget.multiline ? 5 : 2,
        minLines: 1,
        decoration: InputDecoration(hintText: widget.hint),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(s.t('cancel'))),
        FilledButton(onPressed: () => Navigator.pop(context, _c.text), child: Text(s.t('save'))),
      ],
    );
  }
}

Future<bool> showPermissionRationale(BuildContext context) async {
  final s = AppStrings.of(context);
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(s.t('permTitle')),
      content: Text(s.t('permBody')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.t('notNow'))),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(s.t('allow'))),
      ],
    ),
  );
  return r ?? false;
}

String fmtMinutes(BuildContext context, int m) {
  final t = TimeOfDay(hour: m ~/ 60, minute: m % 60);
  return MaterialLocalizations.of(context).formatTimeOfDay(t);
}

/// Note editor: a window at the top of the screen (~45% height), the keyboard stays
/// at the bottom, the text area scrolls, and a Save button sits under it.
class NoteDialog extends StatefulWidget {
  final String title, hint, initial;
  final int maxLength;
  const NoteDialog({super.key, required this.title, required this.hint, this.initial = '', this.maxLength = 500});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final h = MediaQuery.of(context).size.height;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.fromLTRB(14, 36, 14, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        height: h * 0.45,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _c,
                autofocus: true,
                expands: true,
                maxLines: null,
                minLines: null,
                maxLength: widget.maxLength,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(hintText: widget.hint),
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text(s.t('cancel')))),
              const SizedBox(width: 8),
              Expanded(child: FilledButton(onPressed: () => Navigator.pop(context, _c.text), child: Text(s.t('save')))),
            ]),
          ]),
        ),
      ),
    );
  }
}
