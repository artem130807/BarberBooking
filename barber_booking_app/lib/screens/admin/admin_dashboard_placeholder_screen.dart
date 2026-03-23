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
          const SizedBox(height: 16),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
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
          Card(
            margin: const EdgeInsets.only(bottom: 12),
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
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/admin_top_masters'),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: const Text('Топ мастеров'),
                subtitle: const Text(
                  'Рейтинг мастеров выбранного салона',
                ),
                trailing: const Icon(Icons.chevron_right),
                leading: const Icon(Icons.emoji_events_outlined),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/admin_top_services'),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: const Text('Топ услуг'),
                subtitle: const Text(
                  'Самые востребованные услуги в салоне',
                ),
                trailing: const Icon(Icons.chevron_right),
                leading: const Icon(Icons.trending_up_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
