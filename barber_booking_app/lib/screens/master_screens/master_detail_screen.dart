import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:barber_booking_app/models/master_subscription_models/request/create_subscription_request.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/review_params/review_sort_params.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_master_response.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/master_providers/get_master_provider.dart';
import 'package:barber_booking_app/providers/master_subscription_providers/create_subscription_provider.dart';
import 'package:barber_booking_app/providers/master_subscription_providers/delete_subscription_provider.dart';
import 'package:barber_booking_app/providers/review_providers/get_reviews_master_provider.dart';
import 'package:barber_booking_app/utils/date_formatter.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterDetailScreen extends StatefulWidget {
  final String masterId;

  const MasterDetailScreen({super.key, required this.masterId});

  @override
  State<MasterDetailScreen> createState() => _MasterDetailScreenState();
}

class _MasterDetailScreenState extends State<MasterDetailScreen> {
  final PageParams _reviewsPageParams = PageParams(Page: 1, PageSize: 5);
  final ReviewSortParams _reviewSortParams = ReviewSortParams();
  bool _isSubscribed = false;
  String? _subscriptionId;
  int _selectedNavIndex = 0;

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
      final masterProvider = Provider.of<GetMasterProvider>(context, listen: false);
      masterProvider.getMaster(widget.masterId);
      final reviewsProvider = Provider.of<GetReviewsMasterProvider>(context, listen: false);
      reviewsProvider.getReviewsMaster(widget.masterId, _reviewsPageParams, _reviewSortParams);
    });
  }

  Future<void> _toggleSubscription(
    BuildContext context,
    bool currentState,
    String masterId,
    String token,
  ) async {
    if (currentState) {
      if (_subscriptionId == null) return;
      final deleteProvider = Provider.of<DeleteSubscriptionProvider>(context, listen: false);
      final success = await deleteProvider.deleteSubscription(_subscriptionId!);
      if (success && mounted) {
        setState(() {
          _isSubscribed = false;
          _subscriptionId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Мастер удалён из избранного'), duration: Duration(seconds: 1)),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(deleteProvider.errorMessage ?? 'Ошибка при удалении')),
        );
      }
    } else {
      final createProvider = Provider.of<CreateSubscriptionProvider>(context, listen: false);
      final request = CreateSubscriptionRequest(MasterId: masterId);
      final success = await createProvider.createSubscription(request, token);
      if (success && mounted) {
        setState(() {
          _isSubscribed = true;
          _subscriptionId = createProvider.id;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Мастер добавлен в избранное'), duration: Duration(seconds: 1)),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(createProvider.errorMessage ?? 'Ошибка при добавлении')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final token = authProvider.token;

    return Consumer2<GetMasterProvider, GetReviewsMasterProvider>(
      builder: (context, masterProvider, reviewsProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (masterProvider.errorMessage != null && mounted) {
            masterProvider.showApiError(context, masterProvider.errorMessage);
          }
          if (reviewsProvider.errorMessage != null && mounted) {
            reviewsProvider.showApiError(context, reviewsProvider.errorMessage);
          }
        });

        final master = masterProvider.getMasterResponse;

        if (masterProvider.isLoading && master == null) {
          return const Scaffold(
            body: LoadingIndicator(message: 'Загрузка мастера...'),
          );
        }

        if (masterProvider.errorMessage != null && master == null) {
          return Scaffold(
            body: ErrorWidgetCustom(
              message: masterProvider.errorMessage!,
              onRetry: () => masterProvider.getMaster(widget.masterId),
            ),
          );
        }

        if (master == null) {
          return const Scaffold(
            body: Center(
              child: Text('Мастер не найден'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(master.UserName ?? 'Мастер'),
            actions: [
              IconButton(
                icon: Icon(
                  _isSubscribed ? Icons.favorite : Icons.favorite_border,
                  color: _isSubscribed ? Colors.red : null,
                ),
                onPressed: token == null
                    ? null
                    : () => _toggleSubscription(context, _isSubscribed, widget.masterId, token),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(master),
                const SizedBox(height: 24),
                _buildInfoSection(master, context, reviewsProvider),
                const SizedBox(height: 24),
                _buildActionSection(context, master),
              ],
            ),
          ),
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

  Widget _buildHeader(GetMasterResponse master) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              image: master.AvatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(master.AvatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: master.AvatarUrl == null
                ? const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  master.UserName ?? 'Без имени',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  master.Specialization ?? 'Мастер',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      (master.Rating ?? 0).toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${master.RatingCount ?? 0} отзывов)',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
      GetMasterResponse master,
      BuildContext context,
      GetReviewsMasterProvider reviewsProvider,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'О мастере',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            master.Bio?.isNotEmpty == true ? master.Bio! : 'Описание мастера пока не добавлено.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          if (master.SalonNavigation != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Салон',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/salon_screen',
                    arguments: master.SalonNavigation!.Id,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          image: master.SalonNavigation!.MainPhotoUrl != null
                              ? DecorationImage(
                            image: NetworkImage(master.SalonNavigation!.MainPhotoUrl!),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: master.SalonNavigation!.MainPhotoUrl == null
                            ? const Icon(Icons.business, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              master.SalonNavigation!.SalonName ?? 'Салон',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (master.SalonNavigation!.Address != null) ...[
                              Text(
                                '${master.SalonNavigation!.Address!.Street ?? ""}, д. ${master.SalonNavigation!.Address!.HouseNumber ?? ""}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                            ],
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(
                                  (master.SalonNavigation!.Rating ?? 0).toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${master.SalonNavigation!.RatingCount ?? 0})',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Отзывы',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildReviewsSection(reviewsProvider),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(GetReviewsMasterProvider provider) {
    if (provider.isLoading && provider.reviewsList == null) {
      return const LoadingIndicator(message: 'Загрузка отзывов...');
    }

    if (provider.errorMessage != null && provider.reviewsList == null) {
      return ErrorWidgetCustom(
        message: provider.errorMessage!,
        onRetry: () => provider.getReviewsMaster(widget.masterId, _reviewsPageParams, _reviewSortParams),
      );
    }

    if (provider.reviewsList == null || provider.reviewsList!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'У мастера пока нет отзывов',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final reviews = provider.reviewsList!;
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return ReviewTitle(review: review);
          },
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/master_reviews',
                arguments: widget.masterId,
              );
            },
            child: const Text('Все отзывы'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context, GetMasterResponse master) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Записаться к мастеру',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // TODO: навигация к экрану записи
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Выбрать время',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewTitle extends StatelessWidget {
  final GetReviewsMasterResponse review;

  const ReviewTitle({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 20, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        review.UserName ?? 'Аноним',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          review.MasterRating?.toString() ?? '0',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  review.Comment ?? '',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatDateOnly(review.CreatedAt ?? "Неизвестная дата"),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}