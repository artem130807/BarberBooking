class UpdatePasswordResponse {
   String? message;
   bool? isSuccess;
   UpdatePasswordResponse({this.message, this.isSuccess});
   
    factory UpdatePasswordResponse.fromJson(Map<String, dynamic> json){
      return UpdatePasswordResponse(
          message: json['message'],
          isSuccess: json['isSuccess']
      );
    }
}