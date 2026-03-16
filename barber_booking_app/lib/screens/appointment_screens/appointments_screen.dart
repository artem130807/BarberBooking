import 'package:barber_booking_app/models/appointment_models/response/get_appointments_by_client_response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_appointments_by_client_provider.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedNavIndex = 2; // индекс для 'Записи' (0-Главная,1-Поиск,2-Записи,3-Избранное,4-Профиль)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  void _loadAppointments() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) {
      return;
    }
    Provider.of<GetAppointmentsByClientProvider>(context, listen: false)
        .getAppointments(token);
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search_screen');
        break;
      case 2:
        // уже на этом экране
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/favorites_screen');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetAppointmentsByClientProvider>(
      builder: (context, provider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.errorMessage != null && mounted) {
            provider.showApiError(context, provider.errorMessage);
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: const Text('Мои записи'),
            automaticallyImplyLeading: false, // убирает стрелку назад
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Предстоящие'),
                Tab(text: 'Завершённые'),
              ],
            ),
          ),
          body: _buildBody(provider),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedNavIndex,
            onTap: _onNavItemTapped,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Записи'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Избранное'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(GetAppointmentsByClientProvider provider) {
    if (provider.isLoading && provider.list == null) {
      return const LoadingIndicator(message: 'Загрузка записей...');
    }

    if (provider.errorMessage != null && provider.list == null) {
      return ErrorWidgetCustom(
        message: provider.errorMessage!,
        onRetry: _loadAppointments,
      );
    }

    final allAppointments = provider.list ?? [];

    // Пример фильтрации: замените на реальные статусы
    final upcoming = allAppointments.where((a) =>
        a.Status == 'Pending' || a.Status == 'Confirmed').toList();
    final completed = allAppointments.where((a) =>
        a.Status == 'Completed' || a.Status == 'Cancelled').toList();

    return TabBarView(
      controller: _tabController,
      children: [
        _buildList(upcoming, 'Нет предстоящих записей'),
        _buildList(completed, 'Нет завершённых записей'),
      ],
    );
  }

  Widget _buildList(List<GetAppointmentsByClientResponse> appointments, String emptyMessage) {
    final content = appointments.isEmpty
        ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Text(
                  emptyMessage,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          )
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return AppointmentCard(appointment: appointment);
            },
          );
    return RefreshIndicator(
      onRefresh: () async => _loadAppointments(),
      child: content,
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final GetAppointmentsByClientResponse appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final hasSalon = appointment.SalonNavigation?.Id != null;
    final hasMaster = appointment.MasterProfileNavigation?.Id != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Салон и мастер — чипы-ссылки
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _LinkChip(
                  icon: Icons.store_outlined,
                  label: appointment.SalonNavigation?.SalonName ?? 'Салон',
                  onTap: hasSalon
                      ? () => Navigator.pushNamed(
                            context,
                            '/salon_screen',
                            arguments: appointment.SalonNavigation!.Id,
                          )
                      : null,
                ),
                _LinkChip(
                  icon: Icons.person_outline,
                  label: appointment.MasterProfileNavigation?.MasterName ?? 'Мастер',
                  onTap: hasMaster
                      ? () => Navigator.pushNamed(
                            context,
                            '/master_detail',
                            arguments: appointment.MasterProfileNavigation!.Id,
                          )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Услуга
            Text(
              appointment.ServiceName ?? 'Услуга',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            // Дата и время (без секунд)
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  _formatDate(appointment.AppointmentDate),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  '${_formatTime(appointment.StartTime)} – ${_formatTime(appointment.EndTime)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Цена и статус
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${appointment.Price?.Value ?? 0} ₽',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor(appointment.Status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusText(appointment.Status),
                    style: TextStyle(
                      fontSize: 12,
                      color: _statusColor(appointment.Status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Форматирует время без секунд (12:00:00 → 12:00).
  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '--:--';
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
      final date = DateTime.tryParse('1970-01-01 $timeStr');
      if (date != null) {
        return DateFormat('HH:mm').format(date);
      }
      return timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
    } catch (_) {
      return timeStr;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _statusText(String? status) {
    switch (status) {
      case 'Pending':
      case 'Confirmed':
        return 'Предстоит';
      case 'Completed':
        return 'Завершена';
      case 'Cancelled':
        return 'Отменена';
      default:
        return status ?? '';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Pending':
      case 'Confirmed':
        return Colors.green;
      case 'Completed':
        return Colors.blue;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Чип-ссылка для перехода в салон или к мастеру.
class _LinkChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _LinkChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled
          ? Colors.blue.withOpacity(0.08)
          : Colors.grey.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: enabled ? Colors.blue.shade700 : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: enabled ? Colors.blue.shade700 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}