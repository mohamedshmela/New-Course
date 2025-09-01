import 'package:flutter/material.dart';

/*
a normal card with predefined properties that we can use as it is or change them later
*/

class MyCard extends StatelessWidget {
  const MyCard({
    super.key,
    required this.child,
    this.topMargin = 16,
    this.bottomMargin = 16,
    this.rightMargin = 12,
    this.leftMargin = 12,
    this.topPadding = 16,
    this.bottomPadding = 16,
    this.rightPadding = 12,
    this.leftPadding = 12,
  });
  final Widget child;
  final double topMargin;
  final double bottomMargin;
  final double rightMargin;
  final double leftMargin;
  final double topPadding;
  final double bottomPadding;
  final double rightPadding;
  final double leftPadding;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        top: topMargin,
        bottom: bottomMargin,
        right: rightMargin,
        left: leftMargin,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: topPadding,
          bottom: bottomPadding,
          right: rightPadding,
          left: leftPadding,
        ),
        child: child,
      ),
    );
  }
}
