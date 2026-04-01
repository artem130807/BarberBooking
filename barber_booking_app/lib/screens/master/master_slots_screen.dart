import 'package:flutter/material.dart';

class MasterSlotsScreen extends StatelessWidget {
  const MasterSlotsScreen({super.key, required this.masterId});

  final String masterId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Слоты'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule,
                size: 64,
                color: cs.primary.withValues(alpha: 0.85),
              ),
              const SizedBox(height: 16),
              Text(
                'Расписание и слоты',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                masterId.isEmpty
                    ? 'Идентификатор мастера не загружен'
                    : 'Здесь будет управление рабочими окнами и слотами.',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
