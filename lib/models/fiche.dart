class Fiche {
  final String id;
  final String title;
  final String content; // Markdown content
  final String? summary;
  final List<String> keywords;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Fiche({
    required this.id,
    required this.title,
    required this.content,
    this.summary,
    required this.keywords,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Fiche.fromJson(Map<String, dynamic> json) {
    return Fiche(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      summary: json['summary'],
      keywords: List<String>.from(json['keywords'] ?? []),
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': summary,
      'keywords': keywords,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Fiche copyWith({
    String? id,
    String? title,
    String? content,
    String? summary,
    List<String>? keywords,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Fiche(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      keywords: keywords ?? this.keywords,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
