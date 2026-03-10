import 'package:barber_booking_app/models/base/json_serializable.dart';
import 'package:flutter/material.dart';

class GetSlotsRequest extends JsonSerializable{
  String? DateTime;
  String? ServiceDuration;
  GetSlotsRequest({this.DateTime, this.ServiceDuration});
  
  @override
  Map<String, dynamic> toJson() {
      return{
        'dateTime': DateTime,
        'serviceDuration': ServiceDuration
      };
  }
}