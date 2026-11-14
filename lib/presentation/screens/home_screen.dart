import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/fajr_quotes.dart';
import '../../core/security/sanitizer.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../providers.dart';
import '../widgets/common.dart';

const _green = Color(0xFF2E7D32);
const _red = Color(0xFFC62828);

/// Day circle: green = done, red = not done, gold = not decided yet. Ring = selected day.
Widget _badge(BuildContext context, int i, bool? done, bool selected) {
  final bg = done == true ? _green : (done == false ? _red : AppColors.gold);
  final fg = done == null ? AppColors.navy : Colors.white;
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: selected ? Theme.of(context).colorScheme.onSurface : Colors.transparent, width: 2.5),
    ),
    child: CircleAvatar(radius: 22, backgroundColor: bg, child: Text('$i', style: TextStyle(color: fg, fontWeight: FontWeight.bold))),
  );
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final d = ref.watch(daysProvider);
    final n = ref.read(daysProvider.notifier);
    final lang = ref.watch(settingsProvider).lang;
    final e = d.current;
    final quote = (e['quote'] as String?) ?? '';
    final note = (e['note'] as String?) ?? '';
    final done = e['done'] as bool?;

    return ListView(padding: const EdgeInsets.all(16), children: [
      SizedBox(
        height: 84,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (var i = 1; i <= d.count; i++)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 10),
              child: GestureDetector(
                onTap: () => n.select(i),
                child: Column(children: [
                  _badge(context, i, d.entries['$i']?['done'] as bool?, i == d.selected),
                  const SizedBox(height: 4),
                  Text(s.t('dayN', {'n': '$i'}), style: const TextStyle(fontSize: 10)),
                ]),
              ),
            ),
          GestureDetector(
            onTap: n.addDay,
            child: const CircleAvatar(radius: 20, backgroundColor: AppColors.navy, child: Icon(Icons.add, color: Colors.white)),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      CardBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(s.t('dayN', {'n': '${d.selected}'}), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (quote.isNotEmpty)
            Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(quote, textAlign: TextAlign.center, style: const TextStyle(fontStyle: FontStyle.italic))),
          PillButton(label: s.t('addQuote'), onTap: () => _pickQuote(context, ref, lang)),
          const SizedBox(height: 10),
          if (note.isNotEmpty)
            Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(note, textAlign: TextAlign.center)),
          PillButton(label: s.t('myNote'), onTap: () => _editNote(context, ref, note)),
          const SizedBox(height: 16),
          Text(s.t('completed'), textAlign: TextAlign.end, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: PillButton(label: s.t('yes'), icon: Icons.check_circle_outline, color: _green, filled: done == true, onTap: () => n.setDone(true))),
            const SizedBox(width: 12),
            Expanded(child: PillButton(label: s.t('no'), icon: Icons.cancel_outlined, color: _red, filled: done == false, onTap: () => n.setDone(false))),
          ]),
          const SizedBox(height: 12),
          Text(s.t('streak', {'n': '${d.streak}'}), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
        ]),
      ),
    ]);
  }

  Future<void> _editNote(BuildContext context, WidgetRef ref, String current) async {
    final s = AppStrings.of(context);
    final r = await showDialog<String>(
      context: context,
      builder: (_) => NoteDialog(title: s.t('myNote'), hint: s.t('noteHint'), initial: current, maxLength: 500),
    );
    if (r == null) return;
    await ref.read(daysProvider.notifier).setNote(Sanitizer.clean(r, max: 500, multiline: true));
  }

  Future<void> _pickQuote(BuildContext context, WidgetRef ref, String lang) async {
    final r = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _QuoteSheet(lang: lang),
    );
    if (r == null) return;
    await ref.read(daysProvider.notifier).setQuote(Sanitizer.clean(r, max: 400));
  }
}

class _QuoteSheet extends StatefulWidget {
  final String lang;
  const _QuoteSheet({required this.lang});
  @override
  State<_QuoteSheet> createState() => _QuoteSheetState();
}

class _QuoteSheetState extends State<_QuoteSheet> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _c,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: s.t('writeQuote'),
                suffixIcon: IconButton(icon: const Icon(Icons.check), onPressed: () => Navigator.pop(context, _c.text)),
              ),
            ),
          ),
          Text(s.t('pickQuote'), style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.separated(
              itemCount: fajrQuotes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final t = fajrQuotes[i].text(widget.lang);
                return ListTile(title: Text(t), subtitle: Text(fajrQuotes[i].source), onTap: () => Navigator.pop(context, t));
              },
            ),
          ),
        ]),
      ),
    );
  }
}
