import 'package:barber_booking_app/models/appointment_models/response/get_appointment_awaiting_review_response.dart';
import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/services/appointment_services/get_appointment_awaiting_review_service.dart';

class GetAppointmentAwaitingReviewProvider extends BaseProvider {
final GetAppointmentAwaitingReviewService _getAppointmentAwaitingReviewService = GetAppointmentAwaitingReviewService();
List<GetAppointmentAwaitingReviewResponse>? _list;
List<GetAppointmentAwaitingReviewResponse>? get list => _list;

Future<bool?> getAwaitingAppointments(String? token, PageParams pageParams) async{
  startLoading();
  try{
     final response = await _getAppointmentAwaitingReviewService.getAppointments(token, pageParams);
      if(response != null && response.isNotEmpty){
       _list = response;
      finishLoading();  
      notifyListeners();
      return true;
      }else{
        _list = [];
        finishLoading();
        notifyListeners();
        return false;
      }
  }catch(e){
    print(e);
    setError(e.toString());
    finishLoading();
    return false;
  }
}
void clearList() {
  _list = null;
  notifyListeners();
}
}