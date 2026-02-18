import 'package:flutter/material.dart';
abstract class BaseProvider extends ChangeNotifier {

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set errorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }


  void handleError(dynamic error) {
    _isLoading = false;
    _errorMessage = error.toString();
    notifyListeners();
  }


  void startLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void finishLoading() {
    _isLoading = false;
    notifyListeners();
  }
  void showApiError(BuildContext context, String? errorMessage) {
    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
      clearError();
    }
  }
}