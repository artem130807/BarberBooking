import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/service_models/response/service_admin_list_item.dart';
import 'package:barber_booking_app/services/service_services/admin_salon_services_api_service.dart';

class AdminTopServicesProvider extends BaseProvider {
  final AdminSalonServicesApiService _api = AdminSalonServicesApiService();
  final List<ServiceAdminListItem> _items = [];
  int _serverCount = 0;
  int _page = 1;
  static const int _pageSize = 30;
  bool _hasMore = false;
  String? _salonId;

  List<ServiceAdminListItem> get items => List.unmodifiable(_items);
  int get serverCount => _serverCount;
  bool get hasMore => _hasMore;

  Future<void> load(String salonId) async {
    _salonId = salonId;
    _items.clear();
    _page = 1;
    startLoading();
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
    final sid = _salonId;
    if (sid == null || sid.isEmpty) return;
    final params = PageParams(Page: reset ? 1 : _page, PageSize: _pageSize);
    final map = await _api.getTopServicesPaged(sid, params);
    if (map == null) {
      setError('Не удалось загрузить популярные услуги');
      _hasMore = false;
      notifyListeners();
      return;
    }
    clearError();
    final chunk = _api.parseList(map) ?? [];
    _serverCount = _api.parseCount(map);
    if (reset) {
      _items
        ..clear()
        ..addAll(chunk);
      _page = 2;
    } else {
      _items.addAll(chunk);
      _page++;
    }
    _hasMore = _items.length < _serverCount;
    notifyListeners();
  }

  void clearList() {
    _items.clear();
    _serverCount = 0;
    _hasMore = false;
    _salonId = null;
    _page = 1;
    notifyListeners();
  }
}
