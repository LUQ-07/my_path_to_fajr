import 'package:flutter/material.dart';

import '../../l10n/app_strings.dart';
import '../widgets/common.dart';

class UpdatesScreen extends StatelessWidget {
  const UpdatesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return ListView(padding: const EdgeInsets.all(16), children: [
      CardBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.t('updates'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${s.t('version')}: V.1.00', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(s.t('changelog'), style: const TextStyle(height: 1.7)),
        ]),
      ),
    ]);
  }
}
