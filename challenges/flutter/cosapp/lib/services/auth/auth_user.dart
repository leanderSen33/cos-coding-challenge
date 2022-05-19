import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  final String email;
  final String avatarUrl;
  // final bool isEmailVerified; //TODO: Delete this if not needed
  const AuthUser({
    required this.avatarUrl,
    required this.id,
    required this.email,
    // required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        email: user.email!, avatarUrl: user.photoURL!,
        // isEmailVerified: user.emailVerified,
      );
}


// TODO: Task 1: 
//! A profile page containing:

//* User's email
//* User's profile picture
//* User's preferred photo method
  //* Can be switched between Camera and Gallery
  //* Should be stored, so that the settings stay the same after application is closed and reopened

// if (user != null) {
//     for (final providerProfile in user.providerData) {
        // ID of the provider (google.com, apple.cpm, etc.)
//         final provider = providerProfile.providerId;

         // UID specific to the provider
//         final uid = providerProfile.uid;

        // Name, email address, and profile photo URL

//         final emailAddress = providerProfile.email;
//         final profilePhoto = providerProfile.photoURL;
//         final name = providerProfile.displayName;
//     }
// }
//? from: https://firebase.google.com/docs/auth/flutter/manage-users


//* An option to change the user's password
//* An option to change the user's profile picture (please check the user's preferred photo method)
//* An option to logout