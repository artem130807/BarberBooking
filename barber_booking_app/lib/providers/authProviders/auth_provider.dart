import 'package:barber_booking_app/models/Dto/DtoCreateUser.dart';
import 'package:barber_booking_app/models/UserModels/requests/update_password_request.dart';
import 'package:barber_booking_app/models/UserModels/responses/update_password_response.dart';
import 'package:flutter/material.dart';
import 'package:barber_booking_app/services/auth_services/auth_service.dart';
import 'package:barber_booking_app/models/UserModels/requests/login_user_request.dart';
import 'package:barber_booking_app/models/UserModels/requests/register_user_request.dart';
import 'package:barber_booking_app/models/UserModels/responses/auth_response.dart';
import '../../models/base/base_provider.dart';
class AuthProvider extends BaseProvider {
  final AuthService _authService = AuthService();

  AuthResponse? _currentUser;
  bool _isAuthenticated = false;
  String? _verifiedEmail;

  UpdatePasswordResponse? _updatePassword;
  UpdatePasswordResponse? get updatePassword => _updatePassword;
  String? get verifiedEmail => _verifiedEmail;
  AuthResponse? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _currentUser?.token;

  Future<bool> login(String email, String passwordHash) async {
    startLoading();  
    try {
      final request = LoginUserRequest(
        email: email,
        passwordHash: passwordHash,
      );

      final response = await _authService.Login(request);

      if (response != null && response.token != null && response.token!.isNotEmpty) {
        _currentUser = response;
        _isAuthenticated = true;
        finishLoading();  
        notifyListeners();
        return true;
      } else {
        setError(response?.message ?? 'Неверная почта или пароль');  
        finishLoading();
        return false;
      }
    } catch (e) {
      handleError('Ошибка соединения с сервером'); 
      finishLoading();
      return false;
    }
    
  }
  Future<bool> register(RegisterUserRequest request) async {
    startLoading();  
    try {
      final response = await _authService.Register(request);

      if (response != null && response.token != null && response.token!.isNotEmpty) {
        _currentUser = response;
        _isAuthenticated = true;
        finishLoading();  
        notifyListeners();
        return true;
      } else {
        setError(response?.message ?? 'Неверная почта или пароль');  
        finishLoading();
        return false;
      }
    } catch (e) {
      handleError('Ошибка соединения с сервером'); 
      finishLoading();
      return false;
    }
  }
   Future<bool> updatePass(UpdatePasswordRequest request) async {
    startLoading();  
    try {
      final response = await _authService.UpdatePassword(request);

      if (response != null && response.isSuccess == true) {
        _updatePassword = response;
        _isAuthenticated = true;
        finishLoading();  
        notifyListeners();
        return true;
      } else {
        setError(response?.message ?? 'Неверная почта или пароль');  
        finishLoading();
        return false;
      }
    } catch (e) {
      handleError('Ошибка соединения с сервером'); 
      finishLoading();
      return false;
    }
    
  }
  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    resetState();  
    notifyListeners();
  }
  bool isTokenValid() {
    return token != null && token!.isNotEmpty;
  }
  void setVerifiedEmail(String email) {
    _verifiedEmail = email;
    notifyListeners();
  }
  
  void clearVerifiedEmail() {
    _verifiedEmail = null;
    notifyListeners();
  }
}