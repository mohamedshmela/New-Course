import 'package:flutter/material.dart';
import 'package:new_course/models/course_lesson.dart';
import 'package:new_course/screens/lesson_screen.dart';

/*
A list tile with predefined properties 
each tile will represent a lesson in the course's details screen
*/

class LessonCard extends StatelessWidget {
  const LessonCard({super.key, required this.lesson});
  final CourseLesson lesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: BoxBorder.all(width: 1.5),
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        color: Theme.of(context).colorScheme.primaryContainer.withGreen(240),
      ),

      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => LessonScreen(lesson: lesson)),
          );
        },
        leading: const Icon(Icons.play_arrow_rounded),
        title: Text(
          'lesson: ${lesson.lessonNumber}: ${lesson.title}',
          maxLines: 1,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
