import 'package:flutter/material.dart';
import 'package:new_course/screens/main_screen.dart';
import 'package:new_course/widgets/my_text_form_field.dart';
import 'package:new_course/widgets/identifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:http/http.dart' as http;

/*
This screen is responsible for adding new course to the database
it makes sure that title and subtitle are not empty.
it makes sure that the user added atleast one lesson to the course
it makes sure that the user added a valid image url or he should choose to make the course without an image
when the user added lessons, he can see them in a listview builder and he have the ability to delete or edit them after saving 
  - when he chooses to delete the lesson from the list a snack bar appears which gives him the ability to undo 
    so that the lesson will readded to the list at the same index as before 
  - when he chooses to edit the lesson an alert dialog shows with two text fields with initial values represents the current values
    of the lesson. when he saves it again it will update the lesson. 
*/

class AddNewCourseScreen extends StatefulWidget {
  const AddNewCourseScreen({super.key});

  @override
  State<AddNewCourseScreen> createState() => _AddNewCourseScreenState();
}

class _AddNewCourseScreenState extends State<AddNewCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lessonFormKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();

  final _subtitleController = TextEditingController();

  final _imageUrlController = TextEditingController();

  final _newLessonTitleController = TextEditingController();

  final _newLessonUrlController = TextEditingController();

  final List<Map<String, Object>> lessons = [];

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  final coursesCollectionName = 'courses';

  var isSendingData = false;
  var isWaiting = false;
  var courseHasImage = true;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _imageUrlController.dispose();
    _newLessonTitleController.dispose();
    _newLessonUrlController.dispose();
    super.dispose();
  }

  void deleteLesson(int index) {
    /*
    This function deletes the lesson from the list and shows a snackbar that gives the user the ability
    to undo so that the lesson readded again to the list at the same index as before
    */
    var element = lessons.elementAt(index);
    setState(() {
      lessons.removeAt(index);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Lesson deleted'),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  lessons.insert(index, element);
                });
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lesson added again successfully!'),
                  ),
                );
              },
              child: const Text('Undo'),
            ),
          ],
        ),
      ),
    );
  }

  void editLesson(int index) async {
    /*
    This function shows an alert dialog with text fields represents title and url with initial values representing the values saved to the list
    when the user saves these new values the lesson will update.
    */
    String titleValue = lessons[index]['title'].toString();
    String urlValue = lessons[index]['url'].toString();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        elevation: 5,
        scrollable: true,

        title: const Text('Edit this Lesson\'s data'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Identifier(text: 'Title:'),
            const SizedBox(height: 12),
            MyTextFormField(
              hint: 'Edit title',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'enter a valid title';
                }
                return null;
              },
              initialValue: titleValue,
              onChanged: (value) {
                titleValue = value;
              },
            ),
            const SizedBox(height: 12),
            const Identifier(text: 'Url:'),
            const SizedBox(height: 12),
            MyTextFormField(
              hint: 'Edit url',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'enter a valid title';
                }
                return null;
              },
              initialValue: urlValue,
              onChanged: (value) {
                urlValue = value;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  lessons[index]['title'] = titleValue;
                  lessons[index]['url'] = urlValue;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Update this Lesson\'s details'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> isValidImageUrl(String? url) async {
    /*
    This function determines whether the course's image url is valid or not
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

  void saveNewCourse(BuildContext ctx) async {
    /*
    This function makes sure that:
    - The user added atleast one lesson 
    - The user completed all required textfields (title and subtitle)
    - if the user wants to add an image url, it makes sure that this url is valid

    Finally, it structure these data in a specific format to send them to firestore and navigates back to the previous screen.
    */
    if (lessons.isEmpty) {
      _lessonFormKey.currentState!.validate();
      ScaffoldMessenger.of(ctx).clearSnackBars();
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(const SnackBar(content: Text('Add at least one lesson')));
      return;
    }
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(ctx).clearSnackBars();
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Complete all required textfields')),
      );
      return;
    }
    setState(() {
      isWaiting = true;
    });
    if (!await isValidImageUrl(_imageUrlController.text) && courseHasImage) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).clearSnackBars();
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid Image Url or choose not to enter an image. The Image must be available on the internet.',
          ),
        ),
      );
      setState(() {
        isWaiting = false;
      });
      return;
    }

    List<Map<String, Object>> finalLessons = [];

    for (var lesson in lessons) {
      finalLessons.add({
        'lesson_id': lessons.indexOf(lesson) + 1,
        'lesson_title': lesson['title'].toString(),
        'lesson_url': lesson['url'].toString(),
      });
    }

    var response = {
      'course_title': _titleController.text,
      'course_subtitle': _subtitleController.text,
      'course_image_url': courseHasImage ? _imageUrlController.text : null,
      'created_at': DateTime.now(),
      'lessons': finalLessons,
    };
    setState(() {
      isSendingData = true;
    });
    await _firebaseFirestore.collection(coursesCollectionName).add(response);
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).clearSnackBars();
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(const SnackBar(content: Text('Course added successfully')));
    setState(() {
      isSendingData = false;
    });
    Navigator.of(ctx).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    /*
    before the user can navigate back to the previous screen an alert dialog will appear and ask him 
    if he navigates back all data he added will be deleted
    */
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Do you really want to exit the screen?'),
            content: const Text(
              'If you left without saving, every thing you entered will be deleted.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Stay in the same screen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Leave the screen anyway'),
              ),
            ],
          ),
        );
      },
      child: MainScreen.withAppBar(
        appBar: AppBar(
          title: const Text(
            'Add new course',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                saveNewCourse(context);
              },
              icon: const Icon(Icons.save),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        body: isSendingData || isWaiting
            ? Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsetsGeometry.only(
                    top: 16,
                    right: 12,
                    left: 12,
                  ),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Identifier(text: 'Title: '),
                            const SizedBox(height: 12),
                            MyTextFormField(
                              controller: _titleController,
                              hint: 'Enter the course\'s title',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter a valid title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            const Identifier(text: 'Subtitle: '),
                            const SizedBox(height: 12),
                            MyTextFormField(
                              controller: _subtitleController,
                              hint: 'Enter the subtitle',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter a valid subtitle';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  courseHasImage = !courseHasImage;
                                });
                              },
                              label: const Text('Course with no image'),
                              icon: Icon(
                                courseHasImage
                                    ? Icons.check_box_outline_blank
                                    : Icons.check_box,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (courseHasImage)
                              const Identifier(text: 'Course\'s image Url: '),
                            if (courseHasImage) const SizedBox(height: 12),
                            Visibility(
                              visible: courseHasImage,
                              child: MyTextFormField(
                                maxLines: 3,
                                readOnly: !courseHasImage,
                                controller: _imageUrlController,
                                hint: 'Enter the image\'s Url',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter a valid Url';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Center(
                              child: Identifier(text: 'Lessons\'s details'),
                            ),
                            const SizedBox(height: 24),

                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              itemCount: lessons.isEmpty ? 1 : lessons.length,
                              itemBuilder: (ctx, index) {
                                if (lessons.isEmpty) {
                                  return const Card(
                                    elevation: 5,
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Center(
                                        child: Identifier(
                                          text: 'No lessons yet',
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Card(
                                  elevation: 5,
                                  margin: const EdgeInsets.only(bottom: 15),
                                  child: Padding(
                                    padding: const EdgeInsetsGeometry.all(12),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Identifier(
                                              text: 'Lesson: ${index + 1}',
                                            ),
                                            const Spacer(),

                                            IconButton(
                                              onPressed: () {
                                                editLesson(index);
                                              },
                                              icon: const Icon(Icons.settings),
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                deleteLesson(index);
                                              },
                                              icon: const Icon(Icons.delete),
                                              color: Colors.red,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Identifier(text: 'Title: '),
                                            Expanded(
                                              child: Text(
                                                lessons[index]['title']
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Identifier(text: 'Url: '),
                                            Expanded(
                                              child: Text(
                                                lessons[index]['url']
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      Form(
                        key: _lessonFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Identifier(text: 'New lessons\'s title:'),
                            const SizedBox(height: 12),
                            MyTextFormField(
                              controller: _newLessonTitleController,
                              hint: 'Enter the new lesson\'s title',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter a valid title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            const Identifier(
                              text: 'Youtube link for the new lesson',
                            ),
                            const SizedBox(height: 12),
                            MyTextFormField(
                              maxLines: 3,
                              controller: _newLessonUrlController,
                              hint: 'Enter the Youtube link for the new lesson',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'enter a valid url';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_lessonFormKey.currentState!.validate()) {
                                    setState(() {
                                      lessons.add({
                                        'title': _newLessonTitleController.text,
                                        'url': _newLessonUrlController.text,
                                      });
                                      _newLessonTitleController.clear();
                                      _newLessonUrlController.clear();
                                    });
                                  }
                                },
                                child: const Text('Add this Lesson'),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
