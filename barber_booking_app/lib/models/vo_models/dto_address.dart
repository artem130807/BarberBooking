class DtoAddress {
  String? City;
  String? Street; 
  String? HouseNumber;
  String? Apartment; 

  DtoAddress({this.City, this.Street, this.HouseNumber, this.Apartment});

  factory DtoAddress.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    return DtoAddress(
      City: v('city', 'City')?.toString(),
      Street: v('street', 'Street')?.toString(),
      HouseNumber: v('houseNumber', 'HouseNumber')?.toString(),
      Apartment: v('apartment', 'Apartment')?.toString(),
    );
  }
}