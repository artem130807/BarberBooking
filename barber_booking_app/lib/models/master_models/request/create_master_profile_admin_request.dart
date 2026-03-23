class CreateMasterProfileAdminRequest {
  final String emailUser;
  final String salonId;
  final String? bio;
  final String? specialization;
  final String? avatarUrl;

  CreateMasterProfileAdminRequest({
    required this.emailUser,
    required this.salonId,
    this.bio,
    this.specialization,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'emailUser': emailUser,
        'salonId': salonId,
        if (bio != null && bio!.isNotEmpty) 'bio': bio,
        if (specialization != null && specialization!.isNotEmpty)
          'specialization': specialization,
        if (avatarUrl != null && avatarUrl!.isNotEmpty) 'avatarUrl': avatarUrl,
      };
}
