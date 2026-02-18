import 'dart:convert';
import 'package:barber_booking_app/models/userModels/requests/email_verify_request.dart';
import 'package:barber_booking_app/models/userModels/responses/auth_response.dart';
import 'package:barber_booking_app/models/userModels/responses/email_verify_response.dart';
import 'package:http/http.dart' as http;
import 'package:barber_booking_app/models/userModels/requests/send_verification_request.dart';
import 'package:barber_booking_app/models/userModels/responses/send_verification_response.dart';

class EmailVerifyService {
  final String baseUrl = 'http://192.168.0.100:5088';

  Future<SendVerificationResponse?> SendCodeInEmail(SendVerificationRequest request) async{
      try
      {
        final url = Uri.parse('$baseUrl/api/Users/send-verification');
        final requestBody = json.encode(request.toJson());
        final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
        );
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');
        if(response.statusCode == 200){
        return SendVerificationResponse.fromJson(jsonDecode(response.body));
        }else{
        print('❌ Ошибка сервера: ${response.body}');
        return SendVerificationResponse(
          message: response.body
        );
        }
      }
      catch(e)
      {
      print('🔥 Исключение: $e');
      return null;
      }
    
  }
   Future<EmailVerifyResponse?> VerifyCode(EmailVerifyRequest request) async{
      try
      {
        final url = Uri.parse('$baseUrl/api/Users/verify-email');
        final requestBody = json.encode(request.toJson());
        final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
        );
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');
        if(response.statusCode == 200){
        return EmailVerifyResponse.fromJson(jsonDecode(response.body));
        }else{
        print('❌ Ошибка сервера: ${response.body}');
        return  EmailVerifyResponse(
          message: response.body
        );
        }
      }
      catch(e)
      {
      print('🔥 Исключение: $e');
      return null;
      }
    
  }
}