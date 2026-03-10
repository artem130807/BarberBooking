class GetAvailableSlots {
  String? id;         
  String? startTime;   
  String? endTime;    

  GetAvailableSlots({this.id, this.startTime, this.endTime});

  factory GetAvailableSlots.fromJson(Map<String, dynamic> json){
    return GetAvailableSlots(
      id: json['id'],
      startTime: json['startTime'],
      endTime: json['endTime']
    );
  }
}