import 'package:barber_booking_app/models/base/json_serializable.dart';

class PageParams extends JsonSerializable {
  int? Page;
  int? PageSize;
  PageParams({this.Page, this.PageSize});
  
  @override
  Map<String, dynamic> toJson() {
      return{
        'Page':Page,
        'PageSize':PageSize
      };
  }
}