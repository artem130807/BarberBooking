import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_statistic_period_response.dart';
import 'package:barber_booking_app/services/salon_services/salon_statistics_period_service.dart';

enum SalonStatisticPeriodKind { week, month, year }

class SalonStatisticPeriodProvider extends BaseProvider {
  final SalonStatisticsPeriodService _service = SalonStatisticsPeriodService();

  SalonStatisticPeriodResponse? _result;
  SalonStatisticPeriodKind? _lastKind;

  SalonStatisticPeriodResponse? get result => _result;
  SalonStatisticPeriodKind? get lastKind => _lastKind;

  void clear() {
    _result = null;
    _lastKind = null;
    resetState();
  }

  Future<void> loadWeek(String salonId, DateTime anchorInWeek, String? token) async {
    startLoading();
    _lastKind = SalonStatisticPeriodKind.week;
    try {
      final r = await _service.fetchWeek(
        salonId: salonId,
        anchorInWeek: anchorInWeek,
        token: token,
      );
      if (r.error != null) {
        setError(r.error!);
        _result = null;
      } else {
        _result = r.data;
        clearError();
      }
      finishLoading();
    } catch (e) {
      handleError(e);
      _result = null;
    }
  }

  Future<void> loadMonth(String salonId, int year, int month, String? token) async {
    startLoading();
    _lastKind = SalonStatisticPeriodKind.month;
    try {
      final r = await _service.fetchMonth(
        salonId: salonId,
        year: year,
        month: month,
        token: token,
      );
      if (r.error != null) {
        setError(r.error!);
        _result = null;
      } else {
        _result = r.data;
        clearError();
      }
      finishLoading();
    } catch (e) {
      handleError(e);
      _result = null;
    }
  }

  Future<void> loadYear(String salonId, int year, String? token) async {
    startLoading();
    _lastKind = SalonStatisticPeriodKind.year;
    try {
      final r = await _service.fetchYear(
        salonId: salonId,
        year: year,
        token: token,
      );
      if (r.error != null) {
        setError(r.error!);
        _result = null;
      } else {
        _result = r.data;
        clearError();
      }
      finishLoading();
    } catch (e) {
      handleError(e);
      _result = null;
    }
  }
}
