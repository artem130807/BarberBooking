import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_stats_dto.dart';
import 'package:barber_booking_app/services/salon_services/salon_statistics_filter_service.dart';

class SalonStatisticsFilterProvider extends BaseProvider {
  final SalonStatisticsFilterService _service = SalonStatisticsFilterService();
  List<SalonStatsDto>? _items;

  List<SalonStatsDto>? get items => _items;

  Future<void> load({
    required String salonId,
    int? dayOfMonth,
  }) async {
    startLoading();
    try {
      final r = await _service.fetch(
        salonId: salonId,
        dayOfMonth: dayOfMonth,
      );
      if (r.error != null) {
        setError(r.error!);
        _items = null;
      } else {
        _items = r.data;
        clearError();
      }
      finishLoading();
    } catch (e) {
      handleError(e);
      _items = null;
    }
  }

  void clear() {
    _items = null;
    resetState();
  }
}
