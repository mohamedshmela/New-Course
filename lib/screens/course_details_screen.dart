import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_course/models/course.dart';
import 'package:new_course/screens/main_screen.dart';
import 'package:new_course/widgets/lesson_card.dart';

/*
This screen appears when the user choose a specific course 
it will show him cards for each lesson 
when he press on the card it will navigate him to start watching the video of this lesson
*/

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return MainScreen.withAppBar(
      appBar: AppBar(
        title: Text(
          course.title,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 100,
                child: ClipOval(
                  child: course.imageUrl == null
                      ? const Icon(Icons.menu_book_sharp, size: 100)
                      : CachedNetworkImage(
                          imageUrl: course.imageUrl!,
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                          errorWidget: (context, url, error) {
                            return const Icon(Icons.menu_book_sharp);
                          },
                          placeholder: (context, url) {
                            return const Icon(Icons.menu_book_sharp);
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                course.subtitle,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              for (final lesson in course.lessons) LessonCard(lesson: lesson),
            ],
          ),
        ),
      ),
    );
  }
}
