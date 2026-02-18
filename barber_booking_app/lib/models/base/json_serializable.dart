abstract class JsonSerializable {
  Map<String, dynamic> toJson();
  
  static T fromJson<T>(Map<String, dynamic> json) {
    throw UnimplementedError('Implement in child class');
  }
}