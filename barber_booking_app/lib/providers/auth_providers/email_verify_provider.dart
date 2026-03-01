import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/user_models/requests/email_verify_request.dart';
import 'package:barber_booking_app/models/user_models/requests/send_verification_request.dart';
import 'package:barber_booking_app/models/user_models/responses/email_verify_response.dart';
import 'package:barber_booking_app/models/user_models/responses/send_verification_response.dart';
import 'package:barber_booking_app/services/auth_services/email_verify_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class EmailVerifyProvider extends BaseProvider {

  final EmailVerifyService _emailVerifyService = EmailVerifyService();
  SendVerificationResponse? _verificationResponse;
  EmailVerifyResponse? _emailVerifyResponse;

  String? _code;
  String? _verifiedEmail;
  bool _isEmailSent = false;
  
  SendVerificationResponse? get verificationResponse => _verificationResponse;
  EmailVerifyResponse? get emailVerifyResponse => _emailVerifyResponse;

  String? get code => _code;
  String? get verifiedEmail => _verifiedEmail;
  bool get isEmailSent => _isEmailSent;
  Future<bool> sendVerificationCode(String email) async {
    startLoading();
    _isEmailSent = false;
    
    try {
      final request = SendVerificationRequest(email: email);
      final response = await _emailVerifyService.SendCodeInEmail(request);

      if (response != null && response.isSuccess == true) {
        _verificationResponse = response;
        _verifiedEmail = email;
        _isEmailSent = true;
        finishLoading();
        notifyListeners();
        return true;
      } else {
        print(response?.message);
        setError(response?.message ?? 'Ошибка отправки кода'); 
        finishLoading();
        return false;
      }
    } catch (e) {
      handleError('Ошибка соединения с сервером');
      finishLoading();
      return false;
    }
  }
  Future<bool> verificationCode(String code) async{
    startLoading();
    try {
      final request = EmailVerifyRequest(code: code); 
      final response = await _emailVerifyService.VerifyCode(request);
      
      if (response != null && response.isSuccess == true) {
        _code = code;
        finishLoading();
        notifyListeners();
        return true;
      } else {
        print(response?.message);
        setError(response?.message ?? 'Неверный код подтверждения');
        finishLoading();
        return false;
      }
    } catch (e) {
      handleError('Ошибка соединения с сервером');
      finishLoading();
      return false;
    }
  }
  void clearVerification() {
    _verificationResponse = null;
    _verifiedEmail = null;
    _isEmailSent = false;
    resetState();
    notifyListeners();
  }
}