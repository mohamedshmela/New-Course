import 'package:flutter/material.dart';
import 'package:new_course/models/course.dart';
import 'package:new_course/screens/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*
Admins and Super admins can access this screen 
they can use it to see lessons of that course, its image and maybe delete it from the backend
*/

class DeleteCourseScreen extends StatefulWidget {
  const DeleteCourseScreen({super.key, required this.course});

  final Course course;

  @override
  State<DeleteCourseScreen> createState() => _DeleteCourseScreenState();
}

class _DeleteCourseScreenState extends State<DeleteCourseScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  final coursesCollectionName = 'courses';
  bool isDeleting = false;

  void showMySnackBar({required String snackBarContent}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(snackBarContent)));
  }

  Future<void> deleteFromFireStore({
    required BuildContext context,
    required String courseId,
  }) async {
    /*
    When the user needs to delete the course from the backend, this function will try to do this
    and shows snackbar that explains what happened
    */
    try {
      await _firebaseFirestore
          .collection(coursesCollectionName)
          .doc(courseId)
          .delete();
      if (!context.mounted) return;
      showMySnackBar(snackBarContent: 'course deleted successfully!');
    } catch (e) {
      showMySnackBar(
        snackBarContent: 'something went wrong while deleting the course',
      );
    }
  }

  void deleteCourse({required String courseId}) {
    /*
    This function works when the user clicks the button to delete the course so that it will show him an alert dialog 
    and take his response whether to confirm deleting the course or to cancel the operation.
    */
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete this course!!'),
          content: const Text(
            'Are you sure you want to delete this course? if you deleted it, you can\'t undo this operation.',
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  isDeleting = true;
                });

                Navigator.of(context).pop();
                await deleteFromFireStore(context: context, courseId: courseId);
                setState(() {
                  isDeleting = false;
                });
                if (!mounted) return;
                Navigator.of(context).pop(true);
              },
              label: const Text('Yes delete the course'),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              label: const Text('No, keep the course'),
              icon: const Icon(Icons.check, color: Colors.green),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScreen.withAppBar(
      appBar: AppBar(
        title: Text(
          widget.course.title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: isDeleting
                ? null
                : () {
                    deleteCourse(courseId: widget.course.id!);
                  },
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: isDeleting
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    CircleAvatar(
                      radius: 100,
                      child: ClipOval(
                        child: widget.course.imageUrl == null
                            ? const Icon(Icons.menu_book_sharp, size: 100)
                            : Image.network(
                                widget.course.imageUrl!,
                                fit: BoxFit.cover,
                                width: 200,
                                height: 200,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.menu_book_sharp);
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.course.title,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.course.subtitle,
                      softWrap: true,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var lesson in widget.course.lessons)
                            Row(
                              children: [
                                Text(
                                  'Lesson ${lesson.lessonNumber} : ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  lesson.title,
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
