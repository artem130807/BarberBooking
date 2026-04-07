import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/review_params/review_sort_params.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_master_response.dart';
import 'package:barber_booking_app/services/review_services/get_reviews_master_service.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/review_widgets/master_review_card.dart';
import 'package:flutter/material.dart';

enum _MasterReviewSort {
  newest,
  highest,
  lowest,
}

class MasterMyReviewsScreen extends StatefulWidget {
  const MasterMyReviewsScreen({
    super.key,
    required this.masterId,
    this.masterName,
  });

  final String masterId;
  final String? masterName;

  @override
  State<MasterMyReviewsScreen> createState() => _MasterMyReviewsScreenState();
}

class _MasterMyReviewsScreenState extends State<MasterMyReviewsScreen> {
  final GetReviewsMasterService _service = GetReviewsMasterService();
  final ScrollController _scroll = ScrollController();

  List<GetReviewsMasterResponse> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  _MasterReviewSort _sort = _MasterReviewSort.newest;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  ReviewSortParams _sortParams(_MasterReviewSort s) {
    switch (s) {
      case _MasterReviewSort.newest:
        return ReviewSortParams(OrderBy: null, OrderbyDescending: null);
      case _MasterReviewSort.highest:
        return ReviewSortParams(OrderBy: null, OrderbyDescending: true);
      case _MasterReviewSort.lowest:
        return ReviewSortParams(OrderBy: true, OrderbyDescending: null);
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _items = [];
      _hasMore = true;
    });
    final page = await _service.fetchMasterReviewsPage(
      widget.masterId,
      PageParams(Page: 1, PageSize: _pageSize),
      _sortParams(_sort),
    );
    if (!mounted) return;
    if (page == null) {
      setState(() {
        _loading = false;
        _items = [];
      });
      return;
    }
    setState(() {
      _items = page.items;
      _hasMore = _items.length < page.totalCount;
      _loading = false;
    });
  }

  Future<void> _applySort(_MasterReviewSort next) async {
    if (_sort == next) return;
    setState(() => _sort = next);
    await _loadInitial();
  }

  void _onScroll() {
    if (_loadingMore || !_hasMore || _loading) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 120) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final nextPage = (_items.length / _pageSize).floor() + 1;
    final page = await _service.fetchMasterReviewsPage(
      widget.masterId,
      PageParams(Page: nextPage, PageSize: _pageSize),
      _sortParams(_sort),
    );
    if (!mounted) return;
    setState(() {
      _loadingMore = false;
      if (page != null && page.items.isNotEmpty) {
        _items = [..._items, ...page.items];
        _hasMore = _items.length < page.totalCount;
      } else {
        _hasMore = false;
      }
    });
  }

  String _sortLabel(_MasterReviewSort s) {
    switch (s) {
      case _MasterReviewSort.newest:
        return 'Сначала новые';
      case _MasterReviewSort.highest:
        return 'С высокой оценкой';
      case _MasterReviewSort.lowest:
        return 'С низкой оценкой';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Отзывы о вас'),
            if (widget.masterName != null &&
                widget.masterName!.trim().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                widget.masterName!.trim(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.72),
                    ),
              ),
            ],
          ],
        ),
        actions: [
          PopupMenuButton<_MasterReviewSort>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: _applySort,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _MasterReviewSort.newest,
                child: Text(_sortLabel(_MasterReviewSort.newest)),
              ),
              PopupMenuItem(
                value: _MasterReviewSort.highest,
                child: Text(_sortLabel(_MasterReviewSort.highest)),
              ),
              PopupMenuItem(
                value: _MasterReviewSort.lowest,
                child: Text(_sortLabel(_MasterReviewSort.lowest)),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: LoadingIndicator(message: 'Загрузка…'))
          : RefreshIndicator(
              onRefresh: _loadInitial,
              child: _items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.rate_review_outlined,
                                  size: 56,
                                  color: cs.onSurfaceVariant
                                      .withValues(alpha: 0.45),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Пока нет отзывов',
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: _items.length + (_loadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        if (i == _items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }
                        return MasterReviewCard(
                          review: _items[i],
                          colorScheme: cs,
                        );
                      },
                    ),
            ),
    );
  }
}
