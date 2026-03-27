import 'package:barber_booking_app/models/appointment_models/response/salon_appointment_admin_response.dart';
import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/params/appointment_params/filter_appointments_params.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/services/appointment_services/get_salon_appointments_admin_service.dart';

class GetSalonAppointmentsAdminProvider extends BaseProvider {
  final GetSalonAppointmentsAdminService _service =
      GetSalonAppointmentsAdminService();
  List<SalonAppointmentAdminResponse>? _list;
  int _totalCount = 0;

  List<SalonAppointmentAdminResponse>? get list => _list;
  int get totalCount => _totalCount;

  Future<bool> load({
    required String salonId,
    DateTime? from,
    DateTime? to,
    required PageParams pageParams,
    String? token,
    FilterAppointmentsParams? statusFilter,
  }) async {
    startLoading();
    try {
      final map = await _service.getPaged(
        salonId,
        from,
        to,
        pageParams,
        token,
        statusFilter: statusFilter,
      );
      if (map == null) {
        setError('Не удалось загрузить записи');
        finishLoading();
        return false;
      }
      _list = _service.parseData(map) ?? [];
      _totalCount = _service.parseCount(map);
      finishLoading();
      return true;
    } catch (e) {
      handleError(e);
      return false;
    }
  }

  Future<void> loadAllPagesForRevenue({
    required String salonId,
    DateTime? from,
    DateTime? to,
    String? token,
    int pageSize = 100,
    FilterAppointmentsParams? statusFilter,
  }) async {
    startLoading();
    try {
      final all = <SalonAppointmentAdminResponse>[];
      var page = 1;
      while (true) {
        final map = await _service.getPaged(
          salonId,
          from,
          to,
          PageParams(Page: page, PageSize: pageSize),
          token,
          statusFilter: statusFilter,
        );
        if (map == null) {
          setError('Не удалось загрузить записи');
          finishLoading();
          return;
        }
        final chunk = _service.parseData(map) ?? [];
        all.addAll(chunk);
        if (chunk.length < pageSize) break;
        page++;
      }
      _list = all;
      _totalCount = all.length;
      finishLoading();
    } catch (e) {
      handleError(e);
    }
  }

  double sumCompletedRevenue() {
    final items = _list;
    if (items == null) return 0;
    double sum = 0;
    for (final a in items) {
      if (!_isCompleted(a.Status)) continue;
      final v = a.dtoServicesNavigation?.Price?.Value;
      if (v != null) sum += v;
    }
    return sum;
  }

  int countCompleted() {
    final items = _list;
    if (items == null) return 0;
    return items.where((a) => _isCompleted(a.Status)).length;
  }

  bool _isCompleted(String? status) {
    if (status == null) return false;
    final s = status.toLowerCase();
    if (s == 'completed') return true;
    if (s == '1') return true;
    return false;
  }

  void clearList() {
    _list = null;
    _totalCount = 0;
    resetState();
  }
}
