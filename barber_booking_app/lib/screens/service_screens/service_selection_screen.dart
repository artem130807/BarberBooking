import 'package:barber_booking_app/providers/service_providers/get_services_provider.dart';
import 'package:barber_booking_app/screens/time_slot_screens/date_time_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/models/service_models/response/get_services_response.dart';

class ServiceSelectionScreen extends StatefulWidget {
  final String masterName;
  final String masterId;
  final String salonId;

  const ServiceSelectionScreen({
    super.key,
    required this.masterName,
    required this.masterId,
    required this.salonId,
  });

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  GetServicesResponse? _selectedService;

  void _onServicesProviderChanged() {
    if (!mounted) return;
    final p = Provider.of<GetServicesProvider>(context, listen: false);
    final msg = p.errorMessage;
    if (msg != null && msg.isNotEmpty) {
      p.showApiError(context, msg);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<GetServicesProvider>(context, listen: false);
      provider.addListener(_onServicesProviderChanged);
      provider.getServicesForMasterBooking(widget.masterId);
    });
  }

  @override
  void dispose() {
    final p = Provider.of<GetServicesProvider>(context, listen: false);
    p.removeListener(_onServicesProviderChanged);
    p.resetState();
    p.clearList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetServicesProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Запись: ${widget.masterName}'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildBody(GetServicesProvider provider) {
    if (provider.isLoading && (provider.list == null || provider.list!.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && (provider.list == null || provider.list!.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.getServicesForMasterBooking(widget.masterId),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    final services = provider.list;
    if (services == null || services.isEmpty) {
      return const Center(
        child: Text('У мастера нет услуг для записи'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = services[index];
              final isSelected = _selectedService?.Id == service.Id;
              return ServiceCard(
                service: service,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedService = service;
                  });
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedService == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DateTimeSelectionScreen(
                            masterName: widget.masterName,
                            masterId: widget.masterId,
                            serviceId: _selectedService!.Id!,
                            serviceName: _selectedService!.Name ?? 'Услуга',
                            serviceDuration: (_selectedService!.DurationMinutes as num?)?.toInt() ?? 30,
                            salonId: widget.salonId,
                          ),
                        ),
                      );
                    },
              child: const Text('Далее', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }
}

class ServiceCard extends StatelessWidget {
  final GetServicesResponse service;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.18)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.Name ?? 'Без названия',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${service.DurationMinutes ?? 0} мин • ${service.Price?.Value ?? 0} ₽',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}