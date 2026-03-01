import 'package:barber_booking_app/models/salon_models/response/get_salon_response.dart';
import 'package:barber_booking_app/models/salon_models/response/salon.dart';
import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/services/salon_services/get_salon_service.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';

class GetSalonProvider extends BaseProvider{
  final GetSalonService _getSalonService = GetSalonService();

  Salon? _salon;
  Salon? get salon => _salon;
  Future<bool> getSalon(String id) async{
  startLoading();
  try{
    final response = await _getSalonService.getSalon(id);
    if(response != null){
      var result = Salon.fromResponse(response);
      _salon = result;
      finishLoading();
      notifyListeners();
      return true;
    }else{
      print("салон не найден");
      setError("Салон не найден");
      finishLoading();
      return false;
    }
  }catch(e){
    finishLoading();
    setError(e.toString());
    return false;
  }
  }
}