class CreateWeeklyTemplateRequest {
  CreateWeeklyTemplateRequest({
    required this.name,
    required this.isActive,
  });

  final String name;
  final bool isActive;

  Map<String, dynamic> toJson() => {
        'name': name,
        'isActive': isActive,
      };
}
