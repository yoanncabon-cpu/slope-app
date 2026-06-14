class Lesson {
  final String id;
  final String title;
  final String content;
  final int durationMinutes;

  const Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.durationMinutes,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      durationMinutes: json['durationMinutes'] as int,
    );
  }
}
