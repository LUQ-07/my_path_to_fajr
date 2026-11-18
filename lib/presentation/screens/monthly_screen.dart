import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../providers.dart';
import '../widgets/common.dart';

/// A page where the user adds an image (e.g. the monthly session) and can zoom in on it.
class MonthlyScreen extends ConsumerWidget {
  const MonthlyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final path = ref.watch(monthlyImageProvider);
    final n = ref.read(monthlyImageProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(s.t('monthly'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Expanded(
          child: path == null
              ? InkWell(
                  onTap: n.pick,
                  borderRadius: BorderRadius.circular(24),
                  child: CardBox(
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.add_photo_alternate_outlined, size: 56, color: AppColors.gold),
                        const SizedBox(height: 12),
                        Text(s.t('noImage'), textAlign: TextAlign.center),
                      ]),
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 6,
                      child: Center(child: Image.file(File(path), fit: BoxFit.contain, cacheWidth: 2048, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48))),
                    ),
                  ),
                ),
        ),
        if (path != null) ...[
          const SizedBox(height: 8),
          Text(s.t('zoomHint'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: PillButton(label: s.t('changeImage'), icon: Icons.photo_library_outlined, onTap: n.pick)),
            const SizedBox(width: 12),
            Expanded(child: PillButton(label: s.t('deleteImage'), icon: Icons.delete_outline, onTap: n.remove)),
          ]),
        ],
      ]),
    );
  }
}
