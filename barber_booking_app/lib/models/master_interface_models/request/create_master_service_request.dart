class CreateMasterServiceRequest {
  CreateMasterServiceRequest({required this.serviceId});

  final String serviceId;

  Map<String, dynamic> toJson() => {'serviceId': serviceId};
}
