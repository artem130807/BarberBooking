import 'package:barber_booking_app/models/master_models/response/master_navigation_response.dart';

class GetReviewsSalonResponse{

  String? Id;
  MasterNavigationResponse? NavigationResponse;
  String? UserName;
  int? SalonRating;
  int? MasterRating;
  String? Comment;
  String? CreatedAt;

  GetReviewsSalonResponse({this.Id, this.NavigationResponse, this.UserName, this.SalonRating, this.MasterRating, this.Comment, this.CreatedAt});
  
  
  factory GetReviewsSalonResponse.fromJson(Map<String, dynamic> json){
    return GetReviewsSalonResponse(
      Id: json['id'],
      NavigationResponse: json['dtoMasterProfileNavigation'] != null ? MasterNavigationResponse.fromJson(json['dtoMasterProfileNavigation']): null,
      UserName: json['userName'],
      SalonRating: json['salonRating'],
      MasterRating: json['masterRating'],
      Comment: json['comment'],
      CreatedAt: json['createdAt']
    );
  }
}