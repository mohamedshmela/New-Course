import 'package:flutter/material.dart';
import 'package:new_course/models/course_lesson.dart';
import 'package:new_course/screens/main_screen.dart';
import 'package:new_course/widgets/youtube_player.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/*
The screen where the user can watch the lesson.
*/

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lesson});

  final CourseLesson lesson;

  @override
  Widget build(BuildContext context) {
    return MainScreen.withAppBar(
      appBar: AppBar(
        title: Text(
          lesson.title,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          softWrap: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: MyYoutubePlayerIframe(
          videoId: YoutubePlayer.convertUrlToId(lesson.link),
        ),
      ),
    );
  }
}
