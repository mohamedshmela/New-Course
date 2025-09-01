import 'package:flutter/material.dart';

/*
The card which represents each course in the courses screen 
*/

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  final String? imageUrl;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: imageUrl == null
                  ? const Icon(Icons.menu_book_sharp, size: 75)
                  : Image.network(imageUrl!, fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              softWrap: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
