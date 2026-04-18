import 'package:barber_booking_app/models/appointment_models/response/get_appointments_by_client_response.dart';
import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/services/appointment_services/get_appointments_by_client_service.dart';

class GetAppointmentsByClientProvider extends BaseProvider {
  final GetAppointmentsByClientService _getAppointmentsByClientService =
      GetAppointmentsByClientService();

  List<GetAppointmentsByClientResponse>? _list;
  List<GetAppointmentsByClientResponse>? get list => _list;

  Future<bool?> getAppointments() async {
    startLoading();
    try {
      final response = await _getAppointmentsByClientService.getAppointments();
      if (response != null && response.isNotEmpty) {
        _list = response;
        finishLoading();
        notifyListeners();
        return true;
      } else {
        _list = [];
        finishLoading();
        return false;
      }
    } catch (e) {
      print(e);
      finishLoading();
      return false;
    }
  }

  void clearList() {
    _list = null;
    notifyListeners();
  }
}
