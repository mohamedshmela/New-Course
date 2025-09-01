import 'package:flutter/material.dart';

/*
This screen is responsible for designing all screens of the app
*/
class MainScreen extends StatelessWidget {
  const MainScreen.withoutAppBar({
    super.key,
    required this.body,
    this.floatingActionButton,
  }) : appBar = null;

  const MainScreen.withAppBar({
    super.key,
    required this.appBar,
    required this.body,
    this.floatingActionButton,
  });

  final AppBar? appBar;
  final Widget body;
  final FloatingActionButton? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Colors.white,
            ],
            end: Alignment.topLeft,
            begin: Alignment.bottomRight,
          ),
        ),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
