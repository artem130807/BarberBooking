import 'package:barber_booking_app/models/salon_models/response/salon.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salon_provider.dart';
import 'package:barber_booking_app/widgets/booking_button.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_full_address.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_image.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_rating.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SalonScreen extends StatefulWidget {
  final String salonId;

  const SalonScreen({super.key, required this.salonId});

  @override
  State<SalonScreen> createState() => _SalonScreenState();
}

class _SalonScreenState extends State<SalonScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetSalonProvider>(context, listen: false)
          .getSalon(widget.salonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetSalonProvider>(
      builder: (context, salonProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (salonProvider.errorMessage != null && mounted) {
            salonProvider.showApiError(context, salonProvider.errorMessage);
          }
        });

        final salon = salonProvider.salon;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              salon?.name ?? 'Салон',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: false,
          ),
          body: _buildBody(salonProvider, salon),
        );
      },
    );
  }

  Widget _buildBody(GetSalonProvider provider, Salon? salon) {
    if (provider.isLoading && salon == null) {
      return const LoadingIndicator(message: 'Загрузка салона...');
    }

    if (provider.errorMessage != null && salon == null) {
      return ErrorWidgetCustom(
        message: provider.errorMessage!,
        onRetry: () =>
            Provider.of<GetSalonProvider>(context, listen: false)
                .getSalon(widget.salonId),
      );
    }

    if (salon == null) {
      return const Center(
        child: Text(
          'Салон не найден',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final bool isActive = salon.active?.contains('активен') ?? true;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SalonImage(
            imageUrl: salon.mainPhotoUrl,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        salon.name ?? 'Без названия',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (salon.rating != null)
                      SalonRating(
                        rating: salon.rating!,
                        reviewCount: salon.ratingCount ?? 0,
                        size: 18,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (salon.address != null)
                  SalonFullAddress(
                    address: salon.address,
                    distance: 2.5, 
                    showDistance: true
                  ),
                const SizedBox(height: 8),
                if (salon.phone != null)
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        salon.phone!.Number ?? '',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Text(
                      'По записи',
                      style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: isActive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      salon.active ?? (isActive ? 'Активен' : 'Неактивен'),
                      style: TextStyle(
                        fontSize: 14,
                        color: isActive ? Colors.green : Colors.red,
                        fontWeight: isActive ? FontWeight.normal : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Описание',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  salon.description?.isNotEmpty == true
                      ? salon.description!
                      : 'Описание отсутствует',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                BookingButton(
                  onPressed: isActive
                      ? () {
                          
                        }
                      : null,
                  text: 'Записаться в салон',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('На карте'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: salon.phone?.Number != null
                            ? () {
                                
                              }
                            : null,
                        icon: const Icon(Icons.phone_outlined),
                        label: const Text('Позвонить'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}