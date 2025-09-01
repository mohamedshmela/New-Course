/*
The CourseLesson Class defines what a lesson is
each lesson should have:
- a number or id to determine whether this lesson is the first in the course or the second or ...
- a title that represents the content of the lesson
a link to the youtube video which is the lesson itself
 */

class CourseLesson {
  CourseLesson({
    required this.lessonNumber,
    required this.title,
    required this.link,
  });
  final int lessonNumber;
  final String title;
  final String link;
}
