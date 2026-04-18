import 'package:barber_booking_app/models/appointment_models/response/get_appointment_client_response.dart';
import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/services/appointment_services/get_appointment_client_service.dart';

class GetAppointmentClientProvider extends BaseProvider {
  final GetAppointmentClientService _service = GetAppointmentClientService();

  GetAppointmentClientResponse? _appointment;
  GetAppointmentClientResponse? get appointment => _appointment;

  Future<bool> getAppointment(String appointmentId) async {
    startLoading();
    try {
      final response = await _service.getAppointmentById(appointmentId);
      if (response != null) {
        _appointment = response;
        finishLoading();
        notifyListeners();
        return true;
      } else {
        _appointment = null;
        setError('Не удалось загрузить запись');
        finishLoading();
        return false;
      }
    } catch (e) {
      handleError(e);
      return false;
    }
  }

  void clear() {
    _appointment = null;
    resetState();
  }
}
