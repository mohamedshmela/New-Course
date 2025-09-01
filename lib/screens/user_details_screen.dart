import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_course/models/the_user.dart';
import 'package:new_course/screens/main_screen.dart';
import 'package:new_course/widgets/my_elevated_button.dart';

/*
This screen is responsible for:
- changing the user's role 
- Before the user can navigate back to the previous screen, if no changes has been made to the user's role it will navigate him back.
  if he made changes to the user's role and didn't save it will show an alert dialog first to warn him and let the user choose
  whether he needs to save changes before leaving or he don't want to save changes. 
- regardless of the user's actions whether he changed the role or not it will show a snackbar after leaving the screen
  explaining what happened in the backend.
 */

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key, required this.currentUser});
  final TheUser currentUser;

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final chekcedIcon = Icons.check_box;
  final uncheckedIcon = Icons.check_box_outline_blank;
  bool isAdmin = false;
  bool isSuperAdmin = false;
  bool isUser = false;
  bool initialIsAdmin = false;
  bool initialIsSuperAdmin = false;
  bool initialIsUser = false;
  bool isUpdatingData = false;
  final successUpdatingMessage = 'User\'s info updated successfully!';
  final noChangesNeededMessage = 'No changes in this user\'s info';
  final noDataUpdatedMessage =
      'No Date have been updated. We kept the last Data.';
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  static const usersCollectionName = 'users';

  Future<void> updateUserInfo() async {
    /*
    This function works when the user wants to save changes and he already made changes
    it will save the new role to the backend and updates values needed in the screen 
    saving data in the backend may take some time so it changes the value of isUpdatingData variable so that the UI changes according to it.
     */
    setState(() {
      isUpdatingData = true;
    });
    final userDoc = _firebaseFirestore
        .collection(usersCollectionName)
        .doc(widget.currentUser.userEmail);

    await userDoc.update({'isAdmin': isAdmin, 'isSuperAdmin': isSuperAdmin});
    initialIsAdmin = isAdmin;
    initialIsSuperAdmin = isSuperAdmin;
    initialIsUser = isUser;
    setState(() {
      isUpdatingData = false;
    });
  }

  void showMySnackBar({required String snackBarText}) {
    /* 
    This function just clears any past snackbars and shows a new one with the given message
    */
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(snackBarText)));
  }

  void navigateBack() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    /*
    we need to update some variables before running the build method. That's why we update them here in the init state method.
     */
    super.initState();
    isAdmin = widget.currentUser.isAdmin;
    initialIsAdmin = widget.currentUser.isAdmin;

    isSuperAdmin = widget.currentUser.isSuperAdmin;
    initialIsSuperAdmin = widget.currentUser.isSuperAdmin;
    if (!widget.currentUser.isAdmin && !widget.currentUser.isSuperAdmin) {
      isUser = true;
      initialIsUser = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    /*
    when the build method runs we need to know if the user changed anything or not 
    */
    final needsChange =
        initialIsAdmin == isAdmin &&
            initialIsSuperAdmin == isSuperAdmin &&
            initialIsUser == isUser
        ? false
        : true;
    return PopScope(
      /*
      if the user made changes it will prevent him from navigating back and shows the alert dialog
      if he didn't make any changes it will navigate him back normally.
      */
      canPop: !needsChange,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Before Exiting The Screen!'),
            content: const Text('Do you want to save changes before leaving?'),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await updateUserInfo();
                  showMySnackBar(snackBarText: successUpdatingMessage);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: const Text('Yes, update this user\'s info'),
              ),
              TextButton(
                onPressed: () {
                  showMySnackBar(snackBarText: noDataUpdatedMessage);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('No, keep the last data'),
              ),
            ],
          ),
        );
      },
      child: MainScreen.withAppBar(
        appBar: AppBar(
          title: Text(
            widget.currentUser.userName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              /*
              before making an image using Image.network we need to know if the user has a valid image or not
              if he has a valid image the past screen would give him a link to this image
              if he doesn't have a valid image he the value would be null
              */
              widget.currentUser.userPhotoUrl == null
                  ? const CircleAvatar(
                      radius: 100,
                      child: Icon(Icons.person, size: 100),
                    )
                  : CircleAvatar(
                      radius: 100,
                      child: ClipOval(
                        child: Image.network(
                          widget.currentUser.userPhotoUrl!,
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, size: 100);
                          },
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              Text(
                widget.currentUser.userName,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.currentUser.userEmail,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        SizedBox(width: 24),
                        Text(
                          'Change the user\'s role :',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 45,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        children: [
                          const SizedBox(width: 16),
                          /*
                          if we are sending new data to the firestore the buttons will not be clickable
                          if not they will act normally.
                          */
                          ElevatedButton.icon(
                            onPressed: isUpdatingData
                                ? null
                                : () {
                                    setState(() {
                                      /*
                                      if the user pressed the 'super admin' button and the current user is already a super admin so nothing changed
                                      if the current user is not a super admin, let's make him a super admin.
                                      */
                                      if (isSuperAdmin) {
                                        return;
                                      } else {
                                        isSuperAdmin = true;
                                        isAdmin = false;
                                        isUser = false;
                                      }
                                    });
                                  },
                            label: const Text('super admin'),
                            icon: Icon(
                              isSuperAdmin ? chekcedIcon : uncheckedIcon,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: isUpdatingData
                                ? null
                                : () {
                                    setState(() {
                                      if (isAdmin) {
                                        return;
                                      } else {
                                        isAdmin = true;
                                        isSuperAdmin = false;
                                        isUser = false;
                                      }
                                    });
                                  },
                            label: const Text('admin'),
                            icon: Icon(isAdmin ? chekcedIcon : uncheckedIcon),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: isUpdatingData
                                ? null
                                : () {
                                    setState(() {
                                      if (isUser) {
                                        return;
                                      } else {
                                        isUser = true;
                                        isAdmin = false;
                                        isSuperAdmin = false;
                                      }
                                    });
                                  },
                            label: const Text('user'),
                            icon: Icon(isUser ? chekcedIcon : uncheckedIcon),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),

                child: isUpdatingData
                    ? const CircularProgressIndicator()
                    : MyElevatedButton(
                        width: double.infinity,
                        /*
                        if the button is pressed and no changes has been made it will show a snackbar saying so
                        if changes made, it will save them to the back end and show a snack bar as well.
                        */
                        onPressed: !needsChange
                            ? () {
                                showMySnackBar(
                                  snackBarText: noChangesNeededMessage,
                                );
                              }
                            : () async {
                                await updateUserInfo();

                                showMySnackBar(
                                  snackBarText: successUpdatingMessage,
                                );
                              },
                        text: 'Update this user\'s info',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
