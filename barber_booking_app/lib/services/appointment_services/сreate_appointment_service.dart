import 'package:barber_booking_app/models/appointment_models/request/create_appointment_request.dart';
import 'package:http/http.dart' as http;
class CreateAppointmentService{
 final String baseUrl = 'http://192.168.0.100:5088';
 Future createAppointment(CreateAppointmentRequest? request, String? token) async{
  try{
     final url = Uri.parse('$baseUrl/api/Appointment/create-appointment');
     final response = await http.post(
        url,
        headers: 
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: request,
        );
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');

        if (response.statusCode == 200) {
        return true;
        } else {
        print('❌ Ошибка сервера: ${response.body}');
        return false;
        }
  }catch(e){
    print(e);
    return null;
  }
 }
}