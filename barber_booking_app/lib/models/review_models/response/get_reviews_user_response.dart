import 'package:barber_booking_app/models/master_models/response/master_navigation_response.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_navigation_response.dart';

class GetReviewsUserResponse {
  String? Id;
  int? SalonRating;
  int? MasterRating;
  String? ServiceName;
  SalonNavigationResponse? salonNavigationResponse;
  MasterNavigationResponse? masterNavigationResponse;
  String? Comment;
  String? CreatedAt;
  
  GetReviewsUserResponse({this.Id, this.SalonRating, this.MasterRating, this.ServiceName, this.salonNavigationResponse, this.masterNavigationResponse, this.Comment, this.CreatedAt});
}