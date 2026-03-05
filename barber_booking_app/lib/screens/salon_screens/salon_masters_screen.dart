import 'package:barber_booking_app/providers/master_providers/get_masters_provider.dart';
import 'package:barber_booking_app/widgets/booking_button.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/master_widgets/master_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SalonMastersScreen extends StatefulWidget {
  final String salonId;

  const SalonMastersScreen({super.key, required this.salonId});

  @override
  State<SalonMastersScreen> createState() => _SalonMastersScreenState();
}

class _SalonMastersScreenState extends State<SalonMastersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetMastersProvider>(context, listen: false)
          .loadMasters(widget.salonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetMastersProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Выбор мастера'),
          ),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildBody(GetMastersProvider provider) {
    if (provider.isLoading && provider.masters == null) {
      return const Center(
        child: LoadingIndicator(message: 'Загрузка мастеров...'),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: ErrorWidgetCustom(
          message: provider.errorMessage!,
          onRetry: () =>
              Provider.of<GetMastersProvider>(context, listen: false)
                  .loadMasters(widget.salonId),
        ),
      );
    }

    if (provider.masters == null || provider.masters!.isEmpty) {
      return const Center(
        child: ErrorWidgetCustom(
          message: 'В этом салоне пока нет мастеров',
        ),
      );
    }

    final masters = provider.masters!;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: masters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final master = masters[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              MasterCard(
                name: master.UserName ?? 'Без имени',
                specialty: master.Specialization ?? 'Мастер',
                rating: master.Rating ?? 0,
                ratingCount: master.RatingCount ?? 0,
                imageUrl: master.AvatarUrl,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/master_detail',
                    arguments: master,
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BookingButton(
                  onPressed: () {
                    // TODO: переход к выбору услуги и времени для этого мастера
                  },
                  text: 'Записаться',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

