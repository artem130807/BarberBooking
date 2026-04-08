import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_user_response.dart';
import 'package:barber_booking_app/providers/appointment_providers/get_appointment_awaiting_review_provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/review_providers/delete_review_user_provider.dart';
import 'package:barber_booking_app/providers/review_providers/get_reviews_user_provider.dart';
import 'package:barber_booking_app/providers/review_providers/update_review_user_provider.dart';
import 'package:barber_booking_app/screens/user_screens/create_review_screen.dart';
import 'package:barber_booking_app/screens/user_screens/edit_review_screen.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/review_widgets/awaiting_review_card.dart';

class UserReviewsScreen extends StatefulWidget {
  const UserReviewsScreen({super.key});

  @override
  State<UserReviewsScreen> createState() => _UserReviewsScreenState();
}

class _UserReviewsScreenState extends State<UserReviewsScreen> with SingleTickerProviderStateMixin {
  int _selectedNavIndex = 4;
  final PageParams _pageParams = PageParams(Page: 1, PageSize: 20);
  final PageParams _awaitingPageParams = PageParams(Page: 1, PageSize: 20);
  late TabController _tabController;

  GetAppointmentAwaitingReviewProvider? _awaitingForApiErrors;
  GetReviewsUserProvider? _reviewsForApiErrors;

  void _onUserReviewsApiError() {
    if (!mounted) return;
    final a = _awaitingForApiErrors;
    final r = _reviewsForApiErrors;
    if (a != null) {
      final msg = a.errorMessage;
      if (msg != null && msg.isNotEmpty) a.showApiError(context, msg);
    }
    if (r != null) {
      final msg = r.errorMessage;
      if (msg != null && msg.isNotEmpty) r.showApiError(context, msg);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_awaitingForApiErrors != null) return;
    final awaiting = context.read<GetAppointmentAwaitingReviewProvider>();
    final reviews = context.read<GetReviewsUserProvider>();
    _awaitingForApiErrors = awaiting;
    _reviewsForApiErrors = reviews;
    awaiting.addListener(_onUserReviewsApiError);
    reviews.addListener(_onUserReviewsApiError);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });
    _loadReviews();
    _loadAwaiting();
  }

  @override
  void dispose() {
    _awaitingForApiErrors?.removeListener(_onUserReviewsApiError);
    _reviewsForApiErrors?.removeListener(_onUserReviewsApiError);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;
    await Provider.of<GetReviewsUserProvider>(context, listen: false)
        .getReviews(token, _pageParams);
  }

  Future<void> _loadAwaiting() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;
    await Provider.of<GetAppointmentAwaitingReviewProvider>(context, listen: false)
        .getAwaitingAppointments(token, _awaitingPageParams);
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
  Widget build(BuildContext context) {
    return Consumer2<GetAppointmentAwaitingReviewProvider, GetReviewsUserProvider>(
      builder: (context, awaitingProvider, reviewsProvider, child) {
        final bg = Theme.of(context).scaffoldBackgroundColor;
        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            title: const Text('Отзывы'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Мои отзывы'),
                Tab(text: 'Ожидающие отзыва'),
              ],
            ),
          ),
          body: ColoredBox(
            color: bg,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              child: _tabController.index == 0
                  ? KeyedSubtree(
                      key: const ValueKey('my_reviews'),
                      child: _buildMyReviewsPage(reviewsProvider),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('awaiting'),
                      child: _buildAwaitingPage(awaitingProvider),
                    ),
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

  Widget _buildMyReviewsPage(GetReviewsUserProvider reviewsProvider) {
    return RefreshIndicator(
      onRefresh: () async => _loadReviews(),
      child: _buildReviewsSection(reviewsProvider),
    );
  }

  Widget _buildAwaitingPage(GetAppointmentAwaitingReviewProvider awaitingProvider) {
    return RefreshIndicator(
      onRefresh: () async => _loadAwaiting(),
      child: _buildAwaitingSection(awaitingProvider),
    );
  }

  Widget _buildAwaitingSection(GetAppointmentAwaitingReviewProvider provider) {
    Widget content;
    if (provider.isLoading && provider.list == null) {
      content = const SizedBox(
        height: 200,
        child: Center(child: LoadingIndicator(message: 'Загрузка записей...')),
      );
    } else if (provider.errorMessage != null && provider.list == null) {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ErrorWidgetCustom(
          message: provider.errorMessage!,
          onRetry: _loadAwaiting,
        ),
      );
    } else if (provider.list == null || provider.list!.isEmpty) {
      final cs = Theme.of(context).colorScheme;
      content = Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: cs.onSurfaceVariant, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Нет записей, ожидающих отзыва',
                  style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: provider.list!
              .map(
                (item) => AwaitingReviewCard(
                  item: item,
                  onLeaveReview: () async {
                    final created = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateReviewScreen(appointment: item),
                      ),
                    );
                    if (created == true && mounted) {
                      _loadAwaiting();
                      _loadReviews();
                    }
                  },
                ),
              )
              .toList(),
        ),
      );
    }
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: content,
    );
  }

  Widget _buildReviewsSection(GetReviewsUserProvider provider) {
    Widget content;
    if (provider.isLoading && (provider.list == null || provider.list!.isEmpty)) {
      content = const SizedBox(
        height: 200,
        child: Center(child: LoadingIndicator(message: 'Загрузка отзывов...')),
      );
    } else if (provider.errorMessage != null && provider.list == null) {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ErrorWidgetCustom(
          message: provider.errorMessage!,
          onRetry: _loadReviews,
        ),
      );
    } else if (provider.list == null || provider.list!.isEmpty) {
      final cs = Theme.of(context).colorScheme;
      content = Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'У вас пока нет отзывов',
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
          ),
        ),
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: provider.list!.map((review) => _buildReviewCard(review)).toList(),
        ),
      );
    }
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: content,
    );
  }

  Widget _buildReviewCard(GetReviewsUserResponse review) {
    final cs = Theme.of(context).colorScheme;
    final salon = review.dtoSalonNavigation;
    final master = review.masterProfileNavigation;
    final appointment = review.dtoAppointmentNavigation;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outline.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: _buildLinkChip(
                    icon: Icons.store_outlined,
                    label: salon?.SalonName ?? 'Салон',
                    onTap: salon?.Id != null
                        ? () => Navigator.pushNamed(context, '/salon_screen', arguments: salon!.Id)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(review.CreatedAt),
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (master != null || appointment?.ServiceName != null) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (master != null)
                    _buildLinkChip(
                      icon: Icons.person_outline,
                      label: master.MasterName ?? 'Мастер',
                      onTap: master.Id != null
                          ? () => Navigator.pushNamed(context, '/master_detail', arguments: master.Id)
                          : null,
                    ),
                  if (appointment?.ServiceName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        appointment!.ServiceName!,
                        style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                if (review.SalonRating != null) ...[
                  Icon(Icons.star, color: cs.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Салон: ${review.SalonRating}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface),
                  ),
                  const SizedBox(width: 12),
                ],
                if (review.MasterRating != null) ...[
                  Icon(Icons.star, color: cs.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Мастер: ${review.MasterRating}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (review.Comment != null && review.Comment!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  review.Comment!,
                  style: TextStyle(fontSize: 14, color: cs.onSurface),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) {
                        final dcs = Theme.of(ctx).colorScheme;
                        return AlertDialog(
                          backgroundColor: dcs.surface,
                          title: Text('Удалить отзыв?', style: TextStyle(color: dcs.onSurface)),
                          content: Text(
                            'Отзыв будет удалён без возможности восстановления.',
                            style: TextStyle(color: dcs.onSurfaceVariant),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('Отмена', style: TextStyle(color: dcs.onSurfaceVariant)),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: dcs.error),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Удалить'),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirmed != true || !mounted) return;
                    final deleted = await Provider.of<DeleteReviewUserProvider>(context, listen: false)
                        .deleteReview(review.Id);
                    if (!mounted) return;
                    if (deleted) {
                      _loadReviews();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Отзыв удалён'), behavior: SnackBarBehavior.floating),
                      );
                    } else {
                      Provider.of<DeleteReviewUserProvider>(context, listen: false)
                          .showApiError(context, Provider.of<DeleteReviewUserProvider>(context, listen: false).errorMessage);
                    }
                  },
                  icon: Icon(Icons.delete_outline, size: 20, color: cs.error),
                  label: Text('Удалить', style: TextStyle(color: cs.error)),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditReviewScreen(review: review),
                      ),
                    );
                    if (updated == true && mounted) _loadReviews();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  label: const Text('Редактировать'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkChip({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isTappable = onTap != null;
    return Material(
      color: isTappable ? cs.primary.withOpacity(0.15) : cs.surfaceContainerHighest,
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
                color: isTappable ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isTappable ? cs.primary : cs.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isTappable) ...[
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12, color: cs.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
