import '../../firebase_options.dart';
import 'auth_provider.dart';
import 'auth_user.dart';
import 'package:cosapp/services/auth/auth_exceptions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:developer' as devtools show log;
import 'package:firebase_auth/firebase_auth.dart'
    show EmailAuthProvider, FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      // we want to make sure that after signin in, there is a user.
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthException();
        case 'firebase_auth/user-not-found':
          throw UserNotFoundAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  //   Future<void> updatePassword(String password) async {
  //   var firebaseUser = await _auth.currentUser();
  //   firebaseUser.updatePassword(password);
  // }

  @override
  Future<bool> validateCurrentPassword(String password) async {
    var firebaseUser = FirebaseAuth.instance.currentUser;

    var authCredentials = EmailAuthProvider.credential(
        email: firebaseUser!.email!, password: password);

    try {
      var authResult =
          await firebaseUser.reauthenticateWithCredential(authCredentials);
      return authResult.user != null;
    } catch (e) {
      devtools.log(e.toString());
      return false;
    }
  }

  @override
  void updatePassword(String password) async {
    var firebaseUser = FirebaseAuth.instance.currentUser;
    await firebaseUser?.updatePassword(password);
  }
}
