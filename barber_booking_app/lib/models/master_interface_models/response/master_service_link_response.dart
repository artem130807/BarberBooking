class MasterServiceLinkResponse {
  MasterServiceLinkResponse({
    this.id,
    this.masterProfileId,
    this.serviceId,
    this.serviceName,
  });

  String? id;
  String? masterProfileId;
  String? serviceId;
  String? serviceName;

  factory MasterServiceLinkResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    return MasterServiceLinkResponse(
      id: v('id', 'Id')?.toString(),
      masterProfileId: v('masterProfileId', 'MasterProfileId')?.toString(),
      serviceId: v('serviceId', 'ServiceId')?.toString(),
      serviceName: v('serviceName', 'ServiceName')?.toString(),
    );
  }
}
