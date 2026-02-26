class DtoAddress {
  String? City;
  String? Street; 
  String? HouseNumber;
  String? Apartment; 

  DtoAddress({this.City, this.Street, this.HouseNumber, this.Apartment});

  factory  DtoAddress.fromJson(Map<String, dynamic> json){
      return  DtoAddress(
          City: json['city'],
          Street: json['street'],
          HouseNumber: json['houseNumber'],
          Apartment: json['apartment'],
      );
    }
}