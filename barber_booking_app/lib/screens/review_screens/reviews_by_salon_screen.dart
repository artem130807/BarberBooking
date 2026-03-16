import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/review_params/review_sort_params.dart';
import 'package:barber_booking_app/providers/review_providers/get_reviews_salon_provider.dart';
import 'package:barber_booking_app/widgets/review_widgets/review_salon_title.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';

enum ReviewSortType { newest, highest, lowest }

class ReviewsBySalonScreen extends StatefulWidget {
  final String salonId;

  const ReviewsBySalonScreen({super.key, required this.salonId});

  @override
  State<ReviewsBySalonScreen> createState() => _ReviewsBySalonScreenState();
}

class _ReviewsBySalonScreenState extends State<ReviewsBySalonScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageParams _initialParams =  PageParams(Page: 1, PageSize: 10);
  bool _isLoadingMore = false;
  bool _hasMore = true;
  ReviewSortType _currentSort = ReviewSortType.newest;
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
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  ReviewSortParams _getSortParams(ReviewSortType sort) {
    switch (sort) {
      case ReviewSortType.newest:
        return  ReviewSortParams(OrderBy: null, OrderbyDescending: null);
      case ReviewSortType.highest:
        return  ReviewSortParams(OrderBy: null, OrderbyDescending: true);
      case ReviewSortType.lowest:
        return  ReviewSortParams(OrderBy: true, OrderbyDescending: null);
    }
  }

  Future<void> _loadInitial() async {
    final provider = Provider.of<GetReviewsSalonProvider>(context, listen: false);
    final sortParams = _getSortParams(_currentSort);
    await provider.getReviewsSalon(widget.salonId, _initialParams, sortParams);
    setState(() {
      _hasMore = provider.reviewsList?.length == _initialParams.PageSize;
    });
  }

  Future<void> _loadWithSort(ReviewSortType newSort) async {
    if (newSort == _currentSort) return;
    setState(() => _currentSort = newSort);
    final provider = Provider.of<GetReviewsSalonProvider>(context, listen: false);
    provider.clearList();
    final sortParams = _getSortParams(newSort);
    await provider.getReviewsSalon(widget.salonId, _initialParams, sortParams);
    setState(() {
      _hasMore = provider.reviewsList?.length == _initialParams.PageSize;
    });
  }

  void _onScroll() {
    if (_isLoadingMore || !_hasMore) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    final provider = Provider.of<GetReviewsSalonProvider>(context, listen: false);
    final pageSize = _initialParams.PageSize ?? 10;
    final currentCount = provider.reviewsList?.length ?? 0;
    final nextPage = (currentCount ~/ pageSize) + 1;
    final params = PageParams(Page: nextPage, PageSize: _initialParams.PageSize);
    final sortParams = _getSortParams(_currentSort);

    final result = await provider.getReviewsSalon(widget.salonId, params, sortParams);
    if (result == true) {
      final newCount = provider.reviewsList?.length ?? 0;
      setState(() {
        _hasMore = newCount > currentCount;
      });
    }
    setState(() => _isLoadingMore = false);
  }

  Future<void> _refresh() async {
    final provider = Provider.of<GetReviewsSalonProvider>(context, listen: false);
    provider.clearList();
    final sortParams = _getSortParams(_currentSort);
    await provider.getReviewsSalon(widget.salonId, _initialParams, sortParams);
    setState(() {
      _hasMore = provider.reviewsList?.length == _initialParams.PageSize;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetReviewsSalonProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Все отзывы'),
            actions: [
              PopupMenuButton<ReviewSortType>(
                icon: const Icon(Icons.sort),
                onSelected: _loadWithSort,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: ReviewSortType.newest,
                    child: Text('Сначала новые'),
                  ),
                  const PopupMenuItem(
                    value: ReviewSortType.highest,
                    child: Text('С высокой оценкой'),
                  ),
                  const PopupMenuItem(
                    value: ReviewSortType.lowest,
                    child: Text('С низкой оценкой'),
                  ),
                ],
              ),
            ],
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

  Widget _buildBody(GetReviewsSalonProvider provider) {
    if (provider.isLoading && (provider.reviewsList == null || provider.reviewsList!.isEmpty)) {
      return const Center(child: LoadingIndicator(message: 'Загрузка отзывов...'));
    }

    if (provider.errorMessage != null && (provider.reviewsList == null || provider.reviewsList!.isEmpty)) {
      return Center(
        child: ErrorWidgetCustom(
          message: provider.errorMessage!,
          onRetry: () => _loadInitial(),
        ),
      );
    }

    if (provider.reviewsList == null || provider.reviewsList!.isEmpty) {
      return const Center(
        child: Text(
          'У салона пока нет отзывов',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final reviews = provider.reviewsList!;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == reviews.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final review = reviews[index];
          return ReviewSalonTitle(
            review: review,
            onMasterTap: review.NavigationResponse?.Id != null
                ? () {
                    Navigator.pushNamed(
                      context,
                      '/master_detail',
                      arguments: review.NavigationResponse!.Id,
                    );
                  }
                : null,
          );
        },
      ),
    );
  }
}