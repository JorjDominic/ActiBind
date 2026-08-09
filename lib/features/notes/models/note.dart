class Note {
  const Note({
    required this.id,
    required this.userId,
    required this.title,
    this.content,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String? content;
  final DateTime createdAt;

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String,
    content: json['content'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
