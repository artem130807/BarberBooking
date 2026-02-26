import 'package:barber_booking_app/models/UserModels/requests/update_password_request.dart';
import 'package:barber_booking_app/models/UserModels/responses/update_password_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:barber_booking_app/models/UserModels/requests/login_user_request.dart';
import 'package:barber_booking_app/models/UserModels/requests/register_user_request.dart';
import 'package:barber_booking_app/models/UserModels/responses/auth_response.dart';

class AuthService {
    final String baseUrl = 'http://192.168.0.100:5088';
    
    Future<AuthResponse?> Login(LoginUserRequest request) async
    {
        try {
        print('📦 Получен запрос: email=${request.email}, password=${request.passwordHash}');
        
        final url = Uri.parse('$baseUrl/api/Users/LoginUser');
        print('🌐 URL: $url');
        
        final requestBody = json.encode(request.toJson());
        print('📤 Отправляю: $requestBody');
        
        final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
        );
        
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');
        
        if (response.statusCode == 200) {
        return AuthResponse.fromJson(json.decode(response.body));
        } else {
        print('❌ Ошибка сервера: ${response.body}');
        return AuthResponse(
            message:response.body
        );
        }
        } catch(e) {
        print('🔥 Исключение: $e');
        return null;
        } 
    }
    Future<AuthResponse?> Register(RegisterUserRequest request) async
    {
        try {
        print('📦 Получен запрос: ${request.toJson()}');
        
        final url = Uri.parse('$baseUrl/api/Users/RegisterUser');
        print('🌐 URL: $url');
        
        final requestBody = json.encode(request.toJson());
        print('📤 Отправляю: $requestBody');
        
        final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
        );
        
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');
        
        if (response.statusCode == 200) {
        return AuthResponse.fromJson(json.decode(response.body));
        } else {
        print('❌ Ошибка сервера: ${response.body}');
        return AuthResponse(
            message:response.body
        );
        }
        } catch(e) {
        print('🔥 Исключение: $e');
        return null;
        } 
    }
    Future<UpdatePasswordResponse?> UpdatePassword(UpdatePasswordRequest request) async
    {
        try {
        print('📦 Получен запрос: ${request.toJson()}');
        
        final url = Uri.parse('$baseUrl/api/Users/updatePassword');
        print('🌐 URL: $url');
        
        final requestBody = json.encode(request.toJson());
        print('📤 Отправляю: $requestBody');
        
        final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
        );
        
        print('📥 Статус: ${response.statusCode}');
        print('📥 Ответ: ${response.body}');
        
        if (response.statusCode == 200) {
        return UpdatePasswordResponse.fromJson(json.decode(response.body));
        } else {
        print('❌ Ошибка сервера: ${response.body}');
        return UpdatePasswordResponse(
            message:response.body
        );
        }
        } catch(e) {
        print('🔥 Исключение: $e');
        return null;
        } 
    }
}