class SendVerificationResponse {
   String? message;
   bool? isSuccess;
   SendVerificationResponse({this.message, this.isSuccess});
   
    factory SendVerificationResponse.fromJson(Map<String, dynamic> json){
      return SendVerificationResponse(
          message: json['message'],
          isSuccess: json['isSuccess']
      );
    }
}