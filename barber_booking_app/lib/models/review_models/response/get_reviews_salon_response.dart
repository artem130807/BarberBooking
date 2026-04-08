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
  
  
  factory GetReviewsSalonResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final nav = v('dtoMasterProfileNavigation', 'DtoMasterProfileNavigation');
    return GetReviewsSalonResponse(
      Id: v('id', 'Id')?.toString(),
      NavigationResponse: nav != null
          ? MasterNavigationResponse.fromJson(
              Map<String, dynamic>.from(nav as Map))
          : null,
      UserName: v('userName', 'UserName')?.toString(),
      SalonRating: _parseInt(v('salonRating', 'SalonRating')),
      MasterRating: _parseInt(v('masterRating', 'MasterRating')),
      Comment: v('comment', 'Comment')?.toString(),
      CreatedAt: v('createdAt', 'CreatedAt')?.toString(),
    );
  }

  static int? _parseInt(dynamic x) {
    if (x == null) return null;
    if (x is int) return x;
    if (x is num) return x.toInt();
    return int.tryParse(x.toString());
  }
}