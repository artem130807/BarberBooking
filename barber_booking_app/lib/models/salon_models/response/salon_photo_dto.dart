class SalonPhotoDto {
  SalonPhotoDto({required this.id, this.photoUrl});

  final String id;
  final String? photoUrl;

  factory SalonPhotoDto.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    return SalonPhotoDto(
      id: v('id', 'Id').toString(),
      photoUrl: v('photoUrl', 'PhotoUrl')?.toString(),
    );
  }
}
