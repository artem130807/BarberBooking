import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/time_slot_models/request/get_slots_request.dart';
import 'package:barber_booking_app/models/time_slot_models/response/get_available_slots.dart';
import 'package:barber_booking_app/services/time_slot_services/get_slots_service.dart';

class GetSlotsProvider extends BaseProvider {
  final GetSlotsService _getSlotsService = GetSlotsService();
  List<GetAvailableSlots>? _list;
  int _loadSeq = 0;

  List<GetAvailableSlots>? get list => _list;

  void resetForNewScreen() {
    _loadSeq++;
    _list = null;
    resetState();
  }

  Future<bool?> getAvailableSlots(String? masterId, GetSlotsRequest request) async {
    final seq = ++_loadSeq;
    startLoading();
    try {
      final response = await _getSlotsService.getSlots(masterId, request);
      if (seq != _loadSeq) return null;
      if (response != null && response.isNotEmpty) {
        _list = response;
        return true;
      }
      _list = response ?? [];
      if (response == null) {
        setError('Не удалось загрузить слоты');
      }
      return false;
    } catch (e) {
      if (seq != _loadSeq) return null;
      _list = null;
      final msg = e.toString();
      return false;
    } finally {
      if (seq == _loadSeq) {
        finishLoading();
      }
    }
  }

  void clearList() {
    _list = null;
    notifyListeners();
  }
}