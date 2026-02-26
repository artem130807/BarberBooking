class DtoAddressShort {
  String? Street;
  DtoAddressShort({this.Street});
  factory DtoAddressShort.fromJson(Map<String, dynamic> json){
      return DtoAddressShort(
         Street: json['street']
      );
    }
}