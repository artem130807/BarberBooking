class DtoPrice {
  double? Value; 

  DtoPrice({this.Value});

  
   factory DtoPrice.fromJson(Map<String, dynamic> json){
      return  DtoPrice(
        Value: json['value']
      );
    }
}
