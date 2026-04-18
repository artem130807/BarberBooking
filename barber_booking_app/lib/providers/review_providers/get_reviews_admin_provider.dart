import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/review_params/review_admin_filter.dart';
import 'package:barber_booking_app/models/review_models/response/review_admin_list_item.dart';
import 'package:barber_booking_app/services/review_services/get_reviews_admin_service.dart';

class GetReviewsAdminProvider extends BaseProvider {
  final GetReviewsAdminService _service = GetReviewsAdminService();
  final List<ReviewAdminListItem> _items = [];
  int _serverCount = 0;
  int _page = 1;
  static const int _pageSize = 20;
  bool _hasMore = true;
  ReviewAdminFilter _filter = ReviewAdminFilter.empty;

  List<ReviewAdminListItem> get items => List.unmodifiable(_items);
  int get serverCount => _serverCount;
  bool get hasMore => _hasMore;
  ReviewAdminFilter get activeFilter => _filter;

  void setActiveFilter(ReviewAdminFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  Future<void> refresh() async {
    startLoading();
    _items.clear();
    _page = 1;
    _hasMore = true;
    try {
      await _fetchPage(reset: true);
    } finally {
      finishLoading();
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoading) return;
    startLoading();
    try {
      await _fetchPage(reset: false);
    } finally {
      finishLoading();
    }
  }

  Future<void> _fetchPage({required bool reset}) async {
    final params = PageParams(Page: reset ? 1 : _page, PageSize: _pageSize);
    final map = await _service.getAll(
      pageParams: params,
      filter: _filter,
    );
    if (map == null) {
      setError('Не удалось загрузить отзывы');
      _hasMore = false;
      notifyListeners();
      return;
    }
    final chunk = _service.parseData(map) ?? [];
    _serverCount = _service.parseCount(map);
    if (reset) {
      _items
        ..clear()
        ..addAll(chunk);
      _page = 2;
    } else {
      _items.addAll(chunk);
      _page++;
    }
    _hasMore = chunk.length >= _pageSize;
    notifyListeners();
  }
}
