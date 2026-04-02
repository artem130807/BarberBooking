import 'package:barber_booking_app/models/master_interface_models/response/get_master_appointments_short_response.dart';

class PagedMasterAppointmentsResult {
  PagedMasterAppointmentsResult({
    required this.data,
    required this.count,
  });

  final List<GetMasterAppointmentsShortResponse> data;
  final int count;
}
