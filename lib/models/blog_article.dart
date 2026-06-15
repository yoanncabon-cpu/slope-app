class BlogArticle {
  final String id;
  final String title;
  final String category;
  final String icon;
  final String excerpt;
  final List<String> content;
  final int readTimeMinutes;

  const BlogArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.excerpt,
    required this.content,
    required this.readTimeMinutes,
  });

  factory BlogArticle.fromJson(Map<String, dynamic> json) {
    return BlogArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      excerpt: json['excerpt'] as String,
      content: (json['content'] as List).cast<String>(),
      readTimeMinutes: json['readTimeMinutes'] as int,
    );
  }
}
