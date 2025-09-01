import 'package:flutter/material.dart';

/*
a normal elevated button with predefined properties that we can use as it is or change them later
*/

class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width = 300,
    this.height = 50,
    this.fontSize = 20,
  });
  final double width;
  final double height;
  final double fontSize;
  final String text;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, height),
        elevation: 4,
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontSize: fontSize)),
    );
  }
}
