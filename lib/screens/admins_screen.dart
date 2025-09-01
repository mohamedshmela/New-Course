import 'package:flutter/material.dart';
import 'package:new_course/models/the_user.dart';
import 'package:new_course/screens/courses_dashboard_screen.dart';
import 'package:new_course/screens/main_screen.dart';
import 'package:new_course/screens/users_list_screen.dart';
import 'package:new_course/widgets/my_card.dart';
import 'package:new_course/widgets/my_elevated_button.dart';

/*
This screen represents the admin's and super admin's dashboard
both of them will see the courses' control button 
only super admins will see the users' control button 
*/

class AdminsScreen extends StatefulWidget {
  const AdminsScreen({super.key, required this.currentUser});

  final TheUser currentUser;

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  @override
  Widget build(BuildContext context) {
    return MainScreen.withAppBar(
      appBar: AppBar(
        title: Text(
          'Admins Dashboard',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            MyCard(
              child: Column(
                children: [
                  Text(
                    'Courses Control',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  MyElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const CoursesDashboardScreen(),
                        ),
                      );
                    },
                    text: 'All courses',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (widget.currentUser.isSuperAdmin)
              MyCard(
                child: Column(
                  children: [
                    Text(
                      'Users Control',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 24),
                    MyElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const UsersListScreen(),
                          ),
                        );
                      },
                      text: 'All Users',
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
