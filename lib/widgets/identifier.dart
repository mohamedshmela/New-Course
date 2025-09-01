import 'package:flutter/material.dart';

/*
A text widget with predefined styling
*/

class Identifier extends StatelessWidget {
  const Identifier({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}
