import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../providers.dart';
import 'day_screen.dart';

/// Home: the days, 5 per row, wrapping to new rows (scrolls when there are many).
/// Tap a day to open its own page; long-press a day to delete it.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final d = ref.watch(daysProvider);
    final n = ref.read(daysProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          child: LayoutBuilder(builder: (context, c) {
            const gap = 8.0;
            final cell = (c.maxWidth - gap * 4) / 5 - 0.1;
            final radius = (cell / 2 - 5).clamp(16.0, 30.0).toDouble();
            return SingleChildScrollView(
              child: Wrap(
                spacing: gap,
                runSpacing: 12,
                children: [
                  for (var i = 1; i <= d.count; i++)
                    SizedBox(
                      width: cell,
                      child: GestureDetector(
                        onTap: () async {
                          await n.select(i);
                          if (context.mounted) {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DayScreen()));
                          }
                        },
                        onLongPress: () => _confirmDelete(context, s, n, i),
                        child: Column(children: [
                          _badge(context, i, d.entries['$i']?['done'] as bool?, i == d.selected, radius),
                          const SizedBox(height: 4),
                          Text(s.t('dayN', {'n': '$i'}), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
                        ]),
                      ),
                    ),
                  SizedBox(
                    width: cell,
                    child: GestureDetector(
                      onTap: n.addDay,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Center(child: CircleAvatar(radius: radius, backgroundColor: AppColors.navy, child: const Icon(Icons.add, color: Colors.white))),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(s.t('streak', {'n': '${d.streak}'}), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppStrings s, DaysNotifier n, int day) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(s.t('deleteDay')),
        content: Text(s.t('deleteDayMsg', {'n': '$day'})),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(s.t('delete'))),
        ],
      ),
    );
    if (ok == true) await n.deleteDay(day);
  }
}

/// Day circle: green = done, red = not done, gold = not decided yet. Ring = selected day.
Widget _badge(BuildContext context, int i, bool? done, bool selected, double radius) {
  final bg = done == true ? kDayGreen : (done == false ? kDayRed : AppColors.gold);
  final fg = done == null ? AppColors.navy : Colors.white;
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: selected ? Theme.of(context).colorScheme.onSurface : Colors.transparent, width: 2.5),
    ),
    child: CircleAvatar(radius: radius, backgroundColor: bg, child: Text('$i', style: TextStyle(color: fg, fontWeight: FontWeight.bold))),
  );
}
