import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*
This widget is responsible for signing the user with google and adding his data to fire store 
to use it later in the app
*/

class SignInWithGoogleButton extends StatefulWidget {
  const SignInWithGoogleButton({super.key});

  @override
  State<SignInWithGoogleButton> createState() => _SignInWithGoogleButtonState();
}

class _SignInWithGoogleButtonState extends State<SignInWithGoogleButton> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  static const usersCollectionName = 'users';

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return null;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    addUserToFirestore(googleUser);

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> addUserToFirestore(GoogleSignInAccount user) async {
    /*
    ** This function checks if this user's data is present it update his name and photo url
    as these are the two items that may change. we don't want to change his role for example.
    ** If this is the first time for this user to log in and use the app so we will add all his information 
    and makes him a normal user at first. super admins can change his roles later.
    */
    final userDoc = _firebaseFirestore
        .collection(usersCollectionName)
        .doc(user.email);

    final theDoc = await userDoc.get();
    if (theDoc.exists) {
      await userDoc.set({
        'name': user.displayName,
        'photoUrl': user.photoUrl,
      }, SetOptions(mergeFields: ['name', 'photoUrl']));
    } else {
      await userDoc.set({
        'email': user.email,
        'name': user.displayName,
        'photoUrl': user.photoUrl,
        'isAdmin': false,
        'isSuperAdmin': false,
        'createdAt': DateTime.now(),
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: signInWithGoogle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/google_logo.png',
            fit: BoxFit.cover,
            height: 24,
          ),
          const SizedBox(width: 12),
          const Text('Login with Google', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
