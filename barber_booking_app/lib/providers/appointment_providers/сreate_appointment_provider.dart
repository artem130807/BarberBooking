import 'package:barber_booking_app/models/appointment_models/request/create_appointment_request.dart';
import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/services/appointment_services/%D1%81reate_appointment_service.dart';

class CreateAppointmentProvider extends BaseProvider{
  final CreateAppointmentService _createAppointmentService = CreateAppointmentService();
  Future<bool> createAppointment(CreateAppointmentRequest? request, String? token) async{
    startLoading();
    try{
      var response = await _createAppointmentService.createAppointment(request, token);
      if(response == true){
        finishLoading();  
        notifyListeners();
        return true;
      }else{
        finishLoading();  
        return false;
      }
    }catch(e){
      print(e);
      finishLoading();
      return false;
    }
  }
}