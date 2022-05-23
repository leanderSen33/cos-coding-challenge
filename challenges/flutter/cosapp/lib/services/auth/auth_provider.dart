import 'package:cosapp/services/auth/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

// This class is giving us an interface for any authentication provider that we might want to work with.
// For this challenge I will use only Firebase though.

abstract class AuthProvider {
  AuthUser? get currentUser;

  Stream<User?> authStateChanges();

  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset({required String toEmail});

  Future<void> logOut();

  Future<bool> validateCurrentPassword(String password);

  Future<void> updatePassword(String password);
}
