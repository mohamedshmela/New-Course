import 'package:flutter/material.dart';
import 'package:new_course/screens/main_screen.dart';
import 'package:new_course/widgets/logo_title.dart';
import 'package:new_course/widgets/sign_in_with_google_button.dart';

/*
The screen just shows the logo and a button to login using google
*/

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScreen.withAppBar(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            LogoTitle(),
            SizedBox(height: 100),
            SignInWithGoogleButton(),
          ],
        ),
      ),
    );
  }
}
