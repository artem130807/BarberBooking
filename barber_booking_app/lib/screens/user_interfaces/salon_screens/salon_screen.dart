import 'package:barber_booking_app/models/params/review_params/review_sort_params.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/salon_models/response/salon.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salon_provider.dart';
import 'package:barber_booking_app/providers/review_providers/get_reviews_salon_provider.dart';
import 'package:barber_booking_app/widgets/booking_button.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_full_address.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_image.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_rating.dart';
import 'package:barber_booking_app/widgets/review_widgets/salon_review_tile.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/utils/phone_launch.dart';
import 'package:barber_booking_app/utils/salon_working_hours_label.dart';

class SalonScreen extends StatefulWidget {
  final String salonId;

  const SalonScreen({super.key, required this.salonId});

  @override
  State<SalonScreen> createState() => _SalonScreenState();
}

class _SalonScreenState extends State<SalonScreen> {
  final PageParams _reviewsPageParams =  PageParams(Page: 1, PageSize: 5);
  final ReviewSortParams _reviewSortParams = ReviewSortParams();
  int _selectedNavIndex = 0;

  GetSalonProvider? _salonForApiErrors;
  GetReviewsSalonProvider? _reviewsForApiErrors;

  void _onSalonReviewsApiError() {
    if (!mounted) return;
    final s = _salonForApiErrors;
    final r = _reviewsForApiErrors;
    if (s != null) {
      final msg = s.errorMessage;
      if (msg != null && msg.isNotEmpty) s.showApiError(context, msg);
    }
    if (r != null) {
      final msg = r.errorMessage;
      if (msg != null && msg.isNotEmpty) r.showApiError(context, msg);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_salonForApiErrors != null) return;
    final salon = context.read<GetSalonProvider>();
    final reviews = context.read<GetReviewsSalonProvider>();
    _salonForApiErrors = salon;
    _reviewsForApiErrors = reviews;
    salon.addListener(_onSalonReviewsApiError);
    reviews.addListener(_onSalonReviewsApiError);
  }

  @override
  void dispose() {
    _salonForApiErrors?.removeListener(_onSalonReviewsApiError);
    _reviewsForApiErrors?.removeListener(_onSalonReviewsApiError);
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedNavIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search_screen');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/appointments_screen');
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final salonProvider = Provider.of<GetSalonProvider>(context, listen: false);
      salonProvider.getSalon(widget.salonId);

      final reviewsProvider = Provider.of<GetReviewsSalonProvider>(context, listen: false);
      reviewsProvider.getReviewsSalon(widget.salonId, _reviewsPageParams, _reviewSortParams);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GetSalonProvider, GetReviewsSalonProvider>(
      builder: (context, salonProvider, reviewsProvider, child) {
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
          body: _buildBody(salonProvider, reviewsProvider, salon),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedNavIndex,
            onTap: _onNavItemTapped,
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

  Widget _buildBody(
    GetSalonProvider salonProvider,
    GetReviewsSalonProvider reviewsProvider,
    Salon? salon,
  ) {
    if (salonProvider.isLoading && salon == null) {
      return const LoadingIndicator(message: 'Загрузка салона...');
    }

    if (salonProvider.errorMessage != null && salon == null) {
      return ErrorWidgetCustom(
        message: salonProvider.errorMessage!,
        onRetry: () => salonProvider.getSalon(widget.salonId),
      );
    }

    if (salon == null) {
      return Center(
        child: Text(
          'Салон не найден',
          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    final bool isActive = salon.isActive ?? true;

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
                    showDistance: true,
                  ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final phoneText = salon.phone?.Number.trim();
                    if (phoneText == null || phoneText.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final cs = Theme.of(context).colorScheme;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            final ok = await launchPhoneDialer(phoneText);
                            if (!context.mounted) return;
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Не удалось открыть набор номера'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.phone_outlined,
                                    size: 20, color: cs.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    phoneText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: cs.primary,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          decorationColor: cs.primary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Builder(
                  builder: (context) {
                    final hoursLabel =
                        salonWorkingHoursLabel(salon.openingTime, salon.closingTime);
                    final byAppointment = hoursLabel == 'По записи';
                    return Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            hoursLabel,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontStyle: byAppointment
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              fontWeight: byAppointment
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      salon.active ?? (isActive ? 'Активен' : 'Неактивен'),
                      style: TextStyle(
                        fontSize: 14,
                        color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
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
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 24),
                BookingButton(
                  onPressed: isActive
                      ? () {
                          Navigator.pushNamed(
                            context,
                            '/salon_masters',
                            arguments: salon.id,
                          );
                        }
                      : null,
                  text: 'Записаться в салон',
                ),
                const SizedBox(height: 24),
                _buildReviewsSection(reviewsProvider),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(GetReviewsSalonProvider provider) {
    if (provider.isLoading && provider.reviewsList == null) {
      return const LoadingIndicator(message: 'Загрузка отзывов...');
    }

    if (provider.errorMessage != null && provider.reviewsList == null) {
      return ErrorWidgetCustom(
        message: provider.errorMessage!,
        onRetry: () => provider.getReviewsSalon(widget.salonId, _reviewsPageParams, _reviewSortParams),
      );
    }

    if (provider.reviewsList == null || provider.reviewsList!.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Отзывы о салоне',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'У салона пока нет отзывов',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      );
    }

    final reviews = provider.reviewsList!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Отзывы о салоне',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return SalonReviewTile(review: review, onMasterTap: review.NavigationResponse?.Id != null
              ? () {
                  Navigator.pushNamed(
                    context,
                    '/master_detail',
                    arguments: review.NavigationResponse!.Id,
                  );
                }
              : null,);
          },
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/salon_reviews',
                arguments: widget.salonId,
              );
            },
            child: const Text('Все отзывы'),
          ),
        ),
      ],
    );
  }
}