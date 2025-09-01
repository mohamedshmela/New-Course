import 'package:flutter/material.dart';
import 'package:new_course/models/the_user.dart';
import 'package:new_course/screens/admins_screen.dart';
import 'package:new_course/screens/course_details_screen.dart';
import 'package:new_course/screens/main_screen.dart';
import 'package:new_course/widgets/course_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_course/models/course.dart';
import 'package:new_course/models/course_lesson.dart';

import 'package:http/http.dart' as http;

/*
This screen all users can see because it is the main screen where the user can see courses
it is responsible for:
- getting the current user's info 
- getting the current courses data from the backend
if the user is an admin or super admin it will show him a button to take him to the admins dashboard.
*/

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  static const usersCollectionName = 'users';
  final _firestore = FirebaseFirestore.instance;
  final _firebaseAuth = FirebaseAuth.instance;
  final coursesCollectionName = 'courses';

  late final TheUser currentUser;
  bool _isLoading = true;

  Future<bool> isValidImageUrl(String? url) async {
    /*
    This function is responsible for determining whether this user has a valid image url or not
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
    This function is responsible for getting the courses form the backend
    */
    final List<Course> myCoursesList = [];
    final snapshot = await _firestore
        .collection(coursesCollectionName)
        .orderBy('created_at', descending: true)
        .get();
    final docsList = snapshot.docs.map((doc) => doc.data()).toList();
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
        imageUrl: imageUrl,
        title: doc['course_title'],
        subtitle: doc['course_subtitle'],
        lessons: lessonsList,
      );
      myCoursesList.add(newCourse);
    }
    setState(() {
      _isLoading = false;
    });
    return myCoursesList;
  }

  Future<void> getUserData() async {
    /*
    This function is responsible for getting the current user's info 
    and making an object of type TheUser that contains his data
    */
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return;
    }
    final doc = await _firestore
        .collection(usersCollectionName)
        .doc(user.email)
        .get();

    if (!doc.exists) {
      return;
    }
    if (!mounted) return;
    final String? photoUrl = await isValidImageUrl(doc['photoUrl'])
        ? doc['photoUrl']
        : null;
    currentUser = TheUser(
      userName: doc['name'],
      userEmail: doc['email'],
      userPhotoUrl: photoUrl,
      isAdmin: doc['isAdmin'],
      isSuperAdmin: doc['isSuperAdmin'],
    );
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> signOut() async {
    /*
    This function is responsible for signing the user out 
    */
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut();
  }

  @override
  void initState() {
    /*
    we need to get the user's data when the screen builds for the first time
    */
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return MainScreen.withAppBar(
      appBar: AppBar(
        title: Text(
          'All Courses',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: signOut),
        ],
      ),
      body: _isLoading
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    margin: const EdgeInsets.only(
                      top: 24,
                      bottom: 8,
                      right: 24,
                      left: 24,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            currentUser.userEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          if (currentUser.userPhotoUrl == null)
                            const CircleAvatar(
                              radius: 30,
                              child: ClipOval(
                                child: Icon(Icons.person, size: 30),
                              ),
                            ),
                          if (currentUser.userPhotoUrl != null)
                            CircleAvatar(
                              radius: 30,
                              child: ClipOval(
                                child: Image.network(
                                  currentUser.userPhotoUrl!,
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person);
                                  },
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            'Hello ${currentUser.userName} 😀',
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                            softWrap: true,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          if (currentUser.isAdmin || currentUser.isSuperAdmin)
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) =>
                                        AdminsScreen(currentUser: currentUser),
                                  ),
                                );
                                setState(() {
                                  _isLoading = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                              ),
                              child: Text(
                                currentUser.isAdmin
                                    ? 'go to the admins\' screen'
                                    : 'go to the super admins\' screen',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                /*
                We need to wait until the app gets courses' data from the backend
                */
                FutureBuilder(
                  future: getCoursesList(),
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData) {
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
                        ? const Column(
                            children: [
                              SizedBox(height: 100),

                              Center(
                                child: Text(
                                  'No courses now!',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          )
                        : Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                  ),
                              itemCount: coursesList.length,
                              itemBuilder: (ctx, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => CourseDetailsScreen(
                                          course: coursesList[index],
                                        ),
                                      ),
                                    );
                                    setState(() {
                                      _isLoading = true;
                                    });
                                  },
                                  child: CourseCard(
                                    imageUrl: coursesList[index].imageUrl,
                                    title: coursesList[index].title,
                                    subtitle: coursesList[index].subtitle,
                                  ),
                                );
                              },
                            ),
                          );
                  },
                ),
              ],
            ),
    );
  }
}
