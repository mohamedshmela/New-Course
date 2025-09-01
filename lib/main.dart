import 'package:flutter/material.dart';
import 'package:new_course/screens/courses_screen.dart';
import 'package:new_course/screens/login_screen.dart';
import 'package:new_course/screens/waiting_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _firebaseAuth = FirebaseAuth.instance;

  /*
  The main method uses a StreamBuilder to determine which screen should be displayed and 
  changes the screen automatically when the user logs in to direct him to the courses screen
  */

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: _firebaseAuth.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const WaitingScreen();
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const LoginScreen();
          }
          return const CoursesScreen();
        },
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
    );
  }
}
