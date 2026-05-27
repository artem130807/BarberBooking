import 'package:barber_booking_app/models/params/review_params/review_sort_params.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_master_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/providers/review_providers/get_reviews_master_provider.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/navigation/user_bottom_navigation_bar.dart';


enum ReviewSortType { newest, highest, lowest }

class ReviewsByMasterScreen extends StatefulWidget {
  final String masterId;

  const ReviewsByMasterScreen({super.key, required this.masterId});

  @override
  State<ReviewsByMasterScreen> createState() => _ReviewsByMasterScreenState();
}

class _ReviewsByMasterScreenState extends State<ReviewsByMasterScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageParams _initialParams = PageParams(Page: 1, PageSize: 10);
  bool _isLoadingMore = false;
  bool _hasMore = true;
  ReviewSortType _currentSort = ReviewSortType.newest;
  int _selectedNavIndex = 0;

  void _onNavItemTapped(int index) {
    final previousIndex = _selectedNavIndex;
    setState(() => _selectedNavIndex = index);
    if (index == previousIndex) return;
    UserBottomNavigationBar.navigateByIndex(context, index);
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
        return ReviewSortParams(OrderBy: null, OrderbyDescending: null);
      case ReviewSortType.highest:
        return ReviewSortParams(OrderBy: null, OrderbyDescending: true);
      case ReviewSortType.lowest:
        return ReviewSortParams(OrderBy: true, OrderbyDescending: null);
    }
  }

  Future<void> _loadInitial() async {
    final provider = Provider.of<GetReviewsMasterProvider>(context, listen: false);
    final sortParams = _getSortParams(_currentSort);
    await provider.getReviewsMaster(widget.masterId, _initialParams, sortParams);
    setState(() {
      _hasMore = provider.reviewsList?.length == _initialParams.PageSize;
    });
  }

  Future<void> _loadWithSort(ReviewSortType newSort) async {
    if (newSort == _currentSort) return;
    setState(() => _currentSort = newSort);
    final provider = Provider.of<GetReviewsMasterProvider>(context, listen: false);
    provider.clearList(); // ← исправлено: теперь вызываем метод, а не присваиваем
    final sortParams = _getSortParams(newSort);
    await provider.getReviewsMaster(widget.masterId, _initialParams, sortParams);
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

    final provider = Provider.of<GetReviewsMasterProvider>(context, listen: false);
    final pageSize = _initialParams.PageSize ?? 10;
    final currentCount = provider.reviewsList?.length ?? 0;
    final nextPage = (currentCount ~/ pageSize) + 1;
    final params = PageParams(Page: nextPage, PageSize: _initialParams.PageSize);
    final sortParams = _getSortParams(_currentSort);

    final result = await provider.getReviewsMaster(widget.masterId, params, sortParams);
    if (result == true) {
      final newCount = provider.reviewsList?.length ?? 0;
      setState(() {
        _hasMore = newCount > currentCount;
      });
    }
    setState(() => _isLoadingMore = false);
  }

  Future<void> _refresh() async {
    final provider = Provider.of<GetReviewsMasterProvider>(context, listen: false);
    provider.clearList(); // ← исправлено
    final sortParams = _getSortParams(_currentSort);
    await provider.getReviewsMaster(widget.masterId, _initialParams, sortParams);
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
    return Consumer<GetReviewsMasterProvider>(
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
          bottomNavigationBar: UserBottomNavigationBar(
            selectedIndex: _selectedNavIndex,
            onTap: _onNavItemTapped,
          ),
        );
      },
    );
  }

  Widget _buildBody(GetReviewsMasterProvider provider) {
    if (provider.isLoading && (provider.reviewsList == null || provider.reviewsList!.isEmpty)) {
      return const Center(child: LoadingIndicator(message: 'Загрузка отзывов...'));
    }

    if (provider.errorMessage != null && provider.reviewsList == null) {
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
          'У мастера пока нет отзывов',
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
          return ReviewTitle(review: review);
        },
      ),
    );
  }
}

class ReviewTitle extends StatelessWidget {
  const ReviewTitle({super.key, required this.review});

  final GetReviewsMasterResponse review;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.UserName ?? 'Аноним',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${review.MasterRating ?? 0}'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.Comment ?? ''),
          ],
        ),
      ),
    );
  }
}