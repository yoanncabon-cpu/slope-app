import 'lesson.dart';
import 'quiz_question.dart';

enum LearningTrack { investment, entrepreneurship }

class LearningModule {
  final String id;
  final String title;
  final String icon;
  final String colorKey;
  final String summary;
  final String level;
  final int durationMinutes;
  final LearningTrack track;
  final List<Lesson> lessons;
  final List<QuizQuestion> quiz;

  const LearningModule({
    required this.id,
    required this.title,
    required this.icon,
    required this.colorKey,
    required this.summary,
    required this.level,
    required this.durationMinutes,
    required this.track,
    required this.lessons,
    required this.quiz,
  });

  factory LearningModule.fromJson(Map<String, dynamic> json, LearningTrack track) {
    return LearningModule(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
      colorKey: json['colorKey'] as String,
      summary: json['summary'] as String,
      level: json['level'] as String,
      durationMinutes: json['durationMinutes'] as int,
      track: track,
      lessons: (json['lessons'] as List)
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList(),
      quiz: (json['quiz'] as List)
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
