import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/master_models/request/create_master_profile_admin_request.dart';
import 'package:barber_booking_app/models/master_models/response/master_profile_info_admin_response.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/services/master_services/admin_salon_masters_api_service.dart';

class AdminSalonMastersProvider extends BaseProvider {
  final AdminSalonMastersApiService _api = AdminSalonMastersApiService();
  final List<MasterProfileInfoAdminResponse> _items = [];
  int _serverCount = 0;
  int _page = 1;
  static const int _pageSize = 30;
  bool _hasMore = false;
  String? _salonId;

  List<MasterProfileInfoAdminResponse> get items => List.unmodifiable(_items);
  int get serverCount => _serverCount;
  bool get hasMore => _hasMore;

  Future<void> load(String salonId, String? token) async {
    _salonId = salonId;
    _items.clear();
    _page = 1;
    startLoading();
    try {
      await _fetchPage(token, reset: true);
    } finally {
      finishLoading();
    }
  }

  Future<void> loadMore(String? token) async {
    if (!_hasMore || isLoading) return;
    startLoading();
    try {
      await _fetchPage(token, reset: false);
    } finally {
      finishLoading();
    }
  }

  Future<void> _fetchPage(String? token, {required bool reset}) async {
    final sid = _salonId;
    if (sid == null || sid.isEmpty) return;
    final params = PageParams(Page: reset ? 1 : _page, PageSize: _pageSize);
    final map = await _api.getPaged(sid, params, token);
    if (map == null) {
      setError('Не удалось загрузить мастеров');
      _hasMore = false;
      notifyListeners();
      return;
    }
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

  Future<String?> createMaster(
    CreateMasterProfileAdminRequest body,
    String? token,
  ) async {
    startLoading();
    try {
      final err = await _api.createErrorMessage(body, token);
      finishLoading();
      if (err != null) {
        return err;
      }
      if (_salonId != null) await load(_salonId!, token);
      return null;
    } catch (e) {
      handleError(e);
      return e.toString();
    }
  }

  Future<String?> deleteMaster(String masterProfileId, String? token) async {
    startLoading();
    try {
      final err = await _api.deleteMaster(masterProfileId, token);
      finishLoading();
      if (err != null) {
        return err;
      }
      if (_salonId != null) await load(_salonId!, token);
      return null;
    } catch (e) {
      handleError(e);
      return e.toString();
    }
  }

  void clear() {
    _items.clear();
    _salonId = null;
    _serverCount = 0;
    _hasMore = false;
    resetState();
  }
}
