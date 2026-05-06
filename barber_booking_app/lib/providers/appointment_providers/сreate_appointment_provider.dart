import 'package:barber_booking_app/models/appointment_models/request/create_appointment_request.dart';
import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/services/appointment_services/%D1%81reate_appointment_service.dart';

class CreateAppointmentProvider extends BaseProvider{
  final CreateAppointmentService _createAppointmentService = CreateAppointmentService();
  Future<bool> createAppointment(CreateAppointmentRequest? request, String? token) async{
    startLoading();
    try{
      final result = await _createAppointmentService.createAppointment(request, token);
      finishLoading();
      if (result.ok) {
        clearError();
        notifyListeners();
        return true;
      }
      errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }catch(e){
      print(e);
      finishLoading();
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}