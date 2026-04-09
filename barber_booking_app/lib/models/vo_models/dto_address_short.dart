class DtoAddressShort {
  String? Street;
  DtoAddressShort({this.Street});
  factory DtoAddressShort.fromJson(Map<String, dynamic> json){
      return DtoAddressShort(
         Street: json['street'] as String? ?? json['Street'] as String?,
      );
    }
}