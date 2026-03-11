import 'package:flutter/foundation.dart';

class GetMasterprofileSubscriptionInfoResponse {
  String? Id;
  String? MasterName;
  String? AvatarUrl;
  double? Rating;
  GetMasterprofileSubscriptionInfoResponse({this.Id, this.MasterName, this.AvatarUrl, this.Rating});
  factory GetMasterprofileSubscriptionInfoResponse.fromJson(Map<String, dynamic> json){
    return GetMasterprofileSubscriptionInfoResponse(
      Id: json['id'],
      MasterName: json['masterName'],
      AvatarUrl: json['avatarUrl'],
      Rating: json['rating']
    );
  }
}