import 'package:barber_booking_app/models/service_models/response/service_navigation_response.dart';
import 'package:barber_booking_app/models/user_models/responses/user_navigation_response.dart';
import 'package:flutter/material.dart';

class GetAppointmentMasterResponse{
  String? Id;
    String? ClientNotes;
    String? SalonId;
    String? SalonName;
    UserNavigationResponse? userNavigation;
    ServiceNavigationResponse? serviceNavigationResponse;
    String? Status;
    String? StartTime;
    String? EndTime;
    String? AppointmentDate;

    GetAppointmentMasterResponse({this.Id, this.ClientNotes, this.SalonId, this.SalonName, this.userNavigation, this.serviceNavigationResponse, this.Status, this.StartTime, this.EndTime, this.AppointmentDate});

    factory GetAppointmentMasterResponse.fromJson(Map<String, dynamic> json){
      return GetAppointmentMasterResponse(
        Id: json['id'],
        ClientNotes: json['clientNotes'],
        SalonId: json['salonid'],
        SalonName: json['salonName'],
        userNavigation: json['userNavigation'] != null
          ? UserNavigationResponse.fromJson(json['userNavigation'])
          : null,
        serviceNavigationResponse: json['serviceNavigation'] != null
          ? ServiceNavigationResponse.fromJson(json['serviceNavigation'])
          : null,
        Status: json['status'],
        StartTime: json['startTime'],
        EndTime: json['endTime'],
        AppointmentDate: json['appointmentDate']
      );
    }
}