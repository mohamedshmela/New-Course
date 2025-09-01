import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:flutter/material.dart';
import 'package:new_course/models/the_user.dart';
import 'package:new_course/screens/main_screen.dart';
import 'package:new_course/screens/user_details_screen.dart';
import 'package:new_course/widgets/my_search_bar.dart';
import 'package:new_course/widgets/my_user_tile.dart';

import 'package:http/http.dart' as http;

/*
This screen only super admins can access.
It contains:
- A search bar where the user can search for a specific user by part of his name or email.
- A horizontal list view that have three elements each one is reponsible for showing a specific group of users
  if the user uncheck one of them this group will disappear from the list of users
  for example if the user unchecks the admins button the list will contains normal users and super amins only.
- A list of users. Each list tile contains circle avatar that contains the user's photo or a person icon
  then his name and email
When this list tile is pressed the user goes to another screen that contains details about the user he chose 
and options to change his role.
 */

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  static const usersCollectionName = 'users';
  final _firestore = FirebaseFirestore.instance;
  String searchText = '';
  final chekcedIcon = Icons.check_box;
  final uncheckedIcon = Icons.check_box_outline_blank;
  var showSuperAdmins = true;
  var showAdmins = true;
  var showUsers = true;

  Future<bool> isValidImageUrl(String? url) async {
    /*
    This function determines whether the image url represents a real photo or not 
    if it is a real photo it will return true, otherwise it will return false.
    This will helps us later to avoid errors when trying to making the NetworkImage widget with the url.
     */
    if (url == null) return false;
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.startsWith('image/')) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<TheUser>> getUsersList() async {
    /*
    This function returns the list of users that uses the app with their information
    it uses the isValidImageUrl function to choose whether this user has a valid image url or not
     */
    List<TheUser> usersList = [];
    final snapshot = await _firestore.collection(usersCollectionName).get();
    final docsList = snapshot.docs.map((doc) => doc.data()).toList();

    for (final doc in docsList) {
      final String? photoUrl = await isValidImageUrl(doc['photoUrl'])
          ? doc['photoUrl']
          : null;
      final newUser = TheUser(
        userName: doc['name'],
        userEmail: doc['email'],
        userPhotoUrl: photoUrl,
        isAdmin: doc['isAdmin'],
        isSuperAdmin: doc['isSuperAdmin'],
      );
      usersList.add(newUser);
    }
    return usersList;
  }

  @override
  Widget build(BuildContext context) {
    return MainScreen.withAppBar(
      appBar: AppBar(
        title: const Text(
          'Users',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          MySearchBar(
            hintText: 'search by name or email...',
            searchQuery: (query) {
              setState(() {
                searchText = query;
              });
            },
          ),
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 1),
              children: [
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      showSuperAdmins = !showSuperAdmins;
                    });
                  },
                  label: const Text('super admins'),
                  icon: Icon(showSuperAdmins ? chekcedIcon : uncheckedIcon),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      showAdmins = !showAdmins;
                    });
                  },
                  label: const Text('admins'),
                  icon: Icon(showAdmins ? chekcedIcon : uncheckedIcon),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      showUsers = !showUsers;
                    });
                  },
                  label: const Text('users'),
                  icon: Icon(showUsers ? chekcedIcon : uncheckedIcon),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),

          FutureBuilder<List<TheUser>>(
            future: getUsersList(),
            builder: (ctx, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(top: 100),
                    child: const CircularProgressIndicator(),
                  ),
                );
              }
              final users = snapshot.data!;
              final searchedUsers = searchText == ''
                  ? users
                  : users.where((user) {
                      return user.userName.toLowerCase().contains(
                            searchText.toLowerCase(),
                          ) ||
                          user.userEmail.toLowerCase().contains(
                            searchText.toLowerCase(),
                          );
                    }).toList();

              final filteredUsers = searchedUsers.where((user) {
                if (user.isAdmin && showAdmins) return true;
                if (user.isSuperAdmin && showSuperAdmins) return true;
                if (!user.isAdmin && !user.isSuperAdmin && showUsers) {
                  return true;
                } else {
                  return false;
                }
              }).toList();

              return filteredUsers.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (ctx, index) {
                          final user = filteredUsers[index];
                          return MyUserTile(
                            imageUrl: user.userPhotoUrl,
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => UserDetailsScreen(
                                    currentUser: filteredUsers[index],
                                  ),
                                ),
                              );
                              setState(() {});
                            },
                            userEmail: user.userEmail,
                            userName: user.userName,
                            isAdmin: user.isAdmin,
                            isSuperAdmin: user.isSuperAdmin,
                          );
                        },
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.only(top: 100),
                      width: double.infinity,
                      child: const Text(
                        'No users to show. Change filters and search text to see users',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}
