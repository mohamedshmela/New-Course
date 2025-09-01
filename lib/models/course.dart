import 'package:new_course/models/course_lesson.dart';

/*
The Course Class represents what each course should consists of
Each course should contains:
- title
- subtitle: to explain what this course is about in details
- imageUrl: this could be null in cases where the user chose not to enter an image url or the user entered an invalid url
- List of Lessons
- id: which is not required as we don't need it in all cases. We just need it to delete the course from firestore.
*/
class Course {
  Course({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.lessons,
    this.id,
  });
  final String? id;
  final String? imageUrl;
  final String title;
  final String subtitle;
  final List<CourseLesson> lessons;
}
