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
        Navigator.pushReplacementNamed(context, '/search');
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
            selectedItemColor: Colors.black,
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
    if (appointments.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return AppointmentCard(appointment: appointment);
      },
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final GetAppointmentsByClientResponse appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Строка с салоном и мастером
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: appointment.SalonNavigation?.Id != null
                        ? () {
                            Navigator.pushNamed(
                              context,
                              '/salon_screen',
                              arguments: appointment.SalonNavigation!.Id,
                            );
                          }
                        : null,
                    child: Text(
                      appointment.SalonNavigation?.SalonName ?? 'Салон',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: appointment.MasterProfileNavigation?.Id != null
                      ? () {
                          Navigator.pushNamed(
                            context,
                            '/master_detail',
                            arguments: appointment.MasterProfileNavigation!.Id,
                          );
                        }
                      : null,
                  child: Text(
                    appointment.MasterProfileNavigation?.MasterName ?? 'Мастер',
                    style: TextStyle(
                      fontSize: 14,
                      color: appointment.MasterProfileNavigation?.Id != null ? Colors.blue : Colors.grey,
                      decoration: appointment.MasterProfileNavigation?.Id != null
                          ? TextDecoration.underline
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Услуга
            Text(
              appointment.ServiceName ?? 'Услуга',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            // Дата и время
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDate(appointment.AppointmentDate),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${appointment.StartTime} - ${appointment.EndTime}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Цена и статус
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${appointment.Price?.Value ?? 0} ₽',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(appointment.Status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusText(appointment.Status),
                    style: TextStyle(
                      fontSize: 12,
                      color: _statusColor(appointment.Status),
                      fontWeight: FontWeight.w500,
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