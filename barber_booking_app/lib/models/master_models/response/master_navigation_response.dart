class MasterNavigationResponse {
  String? Id;
  String? MasterName;

  MasterNavigationResponse({this.Id, this.MasterName});
  factory MasterNavigationResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    return MasterNavigationResponse(
      Id: v('id', 'Id')?.toString(),
      MasterName: v('masterName', 'MasterName')?.toString(),
    );
  }
}