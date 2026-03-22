import 'package:flutter/material.dart';

class AdminDashboardPlaceholderScreen extends StatelessWidget {
  const AdminDashboardPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Дашборд'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Сводная статистика',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Здесь будут период (сегодня / неделя / месяц), карточки показателей, топ услуг и мастеров, таблица салонов.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Сегодня', 'Неделя', 'Месяц', 'Период']
                .map((e) => Chip(label: Text(e)))
                .toList(),
          ),
          const SizedBox(height: 24),
          Card(
            margin: const EdgeInsets.only(bottom: 20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () =>
                  Navigator.pushNamed(context, '/admin_appointments_period'),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: const Text('Записи за период'),
                subtitle: const Text('Список записей по салону и датам'),
                trailing: const Icon(Icons.chevron_right),
                leading: const Icon(Icons.event_note),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/admin_revenue'),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: const Text('Выручка'),
                subtitle: const Text('По завершённым записям и цене услуги'),
                trailing: const Icon(Icons.chevron_right),
                leading: const Icon(Icons.payments_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
