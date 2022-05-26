import 'package:cosapp/services/auth/auth_provider.dart';
import 'package:cosapp/services/auth/auth_user.dart';
import 'package:cosapp/services/auth/firebase_auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  // We need this in order to return a instance of AuthService that is already configured with a FirebaseAuthProvider.
  // So we don't have to do it everytime we create an AuthService in the UI.
  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(toEmail: toEmail);

  @override
  Future<bool> validateCurrentPassword(String password) async {
    return await provider.validateCurrentPassword(password);
  }

  @override
  Future<void> updatePassword(String password) async {
    provider.updatePassword(password);
  }

  @override
  Stream<User?> authStateChanges() => provider.authStateChanges();
}
