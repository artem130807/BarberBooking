class EmailVerifyResponse {
   String? message;
   bool? isSuccess;
   EmailVerifyResponse({this.message, this.isSuccess});
   
    factory EmailVerifyResponse.fromJson(Map<String, dynamic> json){
      return EmailVerifyResponse(
          message: json['message'],
          isSuccess: json['isSuccess']
      );
    }
}