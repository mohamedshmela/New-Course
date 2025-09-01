import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_course/models/course.dart';
import 'package:new_course/models/course_lesson.dart';
import 'package:new_course/screens/add_new_course_screen.dart';
import 'package:new_course/screens/delete_course_screen.dart';
import 'package:new_course/screens/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:http/http.dart' as http;

/*
This screen shows the list of courses so that admins and super admins can see their details and have the ability to delete them
it contains a floating action button that navigate them to a new screen where they can add new course
After going to the course detail's screen or to the AddNewCourse screen and navigating back to this screen, 
it will refresh if changes made (a course was deleted or added) so that it will shows the current courses  
*/

class CoursesDashboardScreen extends StatefulWidget {
  const CoursesDashboardScreen({super.key});

  @override
  State<CoursesDashboardScreen> createState() => _CoursesDashboardScreenState();
}

class _CoursesDashboardScreenState extends State<CoursesDashboardScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  final coursesCollectionName = 'courses';
  bool isRefreshing = true;

  Future<bool> isValidImageUrl(String? url) async {
    /*
    determining whether the course has valid image url or not
    */
    if (url == null) return false;
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.startsWith('image/')) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<Course>> getCoursesList() async {
    /*
    This function is responsible for getting the courses list and each course doc id which we need to delete this course
    */
    final List<Course> myCoursesList = [];
    final snapshot = await _firebaseFirestore
        .collection(coursesCollectionName)
        .orderBy('created_at', descending: true)
        .get();
    final docsList = snapshot.docs.map((doc) => doc.data()).toList();
    final docsIds = snapshot.docs.map((doc) => doc.id).toList();
    for (int i = 0; i < docsIds.length; i++) {
      docsList[i]['id'] = docsIds[i];
    }
    for (final doc in docsList) {
      final List<CourseLesson> lessonsList = [];
      for (final lesson in doc['lessons']) {
        final newLesson = CourseLesson(
          lessonNumber: lesson['lesson_id'],
          title: lesson['lesson_title'],
          link: lesson['lesson_url'],
        );
        lessonsList.add(newLesson);
      }
      final String? imageUrl = await isValidImageUrl(doc['course_image_url'])
          ? doc['course_image_url']
          : null;

      final newCourse = Course(
        id: doc['id'],
        imageUrl: imageUrl,
        title: doc['course_title'],
        subtitle: doc['course_subtitle'],
        lessons: lessonsList,
      );
      myCoursesList.add(newCourse);
    }
    isRefreshing = false;
    return myCoursesList;
  }

  @override
  Widget build(BuildContext context) {
    return MainScreen.withAppBar(
      appBar: AppBar(
        title: const Text(
          'Courses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getCoursesList(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData || isRefreshing) {
            return Container(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.only(top: 100),
                child: const CircularProgressIndicator(),
              ),
            );
          }
          final coursesList = snapshot.data!;
          return coursesList.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No courses now!',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        Text(
                          'start adding some',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: coursesList.length,
                  itemBuilder: (ctx, index) => Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    elevation: 3,
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      onTap: () async {
                        final bool? needsRefresh = await Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (ctx) => DeleteCourseScreen(
                                  course: coursesList[index],
                                ),
                              ),
                            );
                        if (needsRefresh != null && needsRefresh) {
                          setState(() {
                            isRefreshing = true;
                          });
                        }
                      },
                      leading: CircleAvatar(
                        radius: 25,
                        child: ClipOval(
                          child: coursesList[index].imageUrl == null
                              ? const Icon(Icons.menu_book_sharp)
                              : CachedNetworkImage(
                                  imageUrl: coursesList[index].imageUrl!,
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                  errorWidget: (context, url, error) {
                                    return const Icon(Icons.menu_book_sharp);
                                  },
                                  placeholder: (context, url) {
                                    return const Icon(Icons.menu_book_sharp);
                                  },
                                ),
                        ),
                      ),
                      title: Text(
                        coursesList[index].title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        coursesList[index].subtitle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final shouldRefresh = await Navigator.of(context).push<bool?>(
            MaterialPageRoute(
              builder: (ctx) {
                return const AddNewCourseScreen();
              },
            ),
          );
          if (shouldRefresh != null && shouldRefresh) {
            setState(() {
              isRefreshing = true;
            });
          }
        },
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        child: const Icon(Icons.add),
      ),
    );
  }
}
