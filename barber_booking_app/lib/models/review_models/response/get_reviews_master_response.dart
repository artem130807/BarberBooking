class GetReviewsMasterResponse {
  String? Id;
  String? UserName;
  int? MasterRating;
  String? Comment;
  String? CreatedAt;

  GetReviewsMasterResponse({
    this.Id,
    this.UserName,
    this.MasterRating,
    this.Comment,
    this.CreatedAt,
  });

  factory GetReviewsMasterResponse.fromJson(Map<String, dynamic> json) {
    dynamic v(String a, String b) => json[a] ?? json[b];
    final created = v('createdAt', 'CreatedAt');
    String? createdStr;
    if (created != null) {
      createdStr = created is String
          ? created
          : created.toString();
    }
    return GetReviewsMasterResponse(
      Id: v('id', 'Id')?.toString(),
      UserName: v('userName', 'UserName')?.toString(),
      MasterRating: _parseInt(v('masterRating', 'MasterRating')),
      Comment: v('comment', 'Comment')?.toString(),
      CreatedAt: createdStr,
    );
  }

  static int? _parseInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }
}