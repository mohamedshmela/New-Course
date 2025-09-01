import 'package:flutter/material.dart';

/*
The widget used as a search bar in the user's list screen 
it gives the search text to its parent widget so that it can be used to filter users
*/

class MySearchBar extends StatelessWidget {
  const MySearchBar({
    super.key,
    required this.hintText,
    required this.searchQuery,
  });
  final String? hintText;
  final void Function(String query) searchQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsetsGeometry.all(8),
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onChanged: (query) {
            searchQuery(query.toLowerCase());
          },
        ),
      ),
    );
  }
}
