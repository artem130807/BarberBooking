import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/services/appointment_services/delete_appointment_service.dart';

class DeleteAppointmentProvider extends BaseProvider {
  final DeleteAppointmentService _deleteAppointmentService = DeleteAppointmentService();
  Future<bool> deleteAppointment(String? id) async{
    if (id == null || id.isEmpty) return false;
    startLoading();
    try{
      final response = await _deleteAppointmentService.deleteAppointment(id);
      if(response == true){
        finishLoading();
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