import 'package:flutter/material.dart';
import 'package:new_course/screens/main_screen.dart';
import 'package:new_course/widgets/logo_title.dart';

/*
 This screen appears when the app runs and the connection status is waiting 
 */

class WaitingScreen extends StatelessWidget {
  const WaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScreen.withAppBar(
      appBar: AppBar(title: const Text('Loading...')),
      body: const Column(
        children: [
          LogoTitle(),
          SizedBox(height: 50),
          Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
