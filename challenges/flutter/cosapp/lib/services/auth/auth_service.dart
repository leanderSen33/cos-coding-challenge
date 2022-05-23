// TODO:DELETE. We need an AuthService, why? This is going to also implement AuthProvider. In itself it's going to take an instance of an AuthProvider as well.
// Our AuthService is a Provider in itself, which exposes all the functionalities of the provider that we give it.
// And it's has no other logic. We do this just to learn that we need to have providers and we need to have services that talk to each other.
// and these service can expose more values to our UI, than the provider does.
// To summarize, the Service fuses together a few other provider, and at the end provides this to the UI.
// In our case we will have a priori only one Provider

import 'package:cosapp/services/auth/auth_provider.dart';
import 'package:cosapp/services/auth/auth_user.dart';
import 'package:cosapp/services/auth/firebase_auth_provider.dart';

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
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(toEmail: toEmail);

  @override
  Future<bool> validateCurrentPassword(String password) async {
    return await provider.validateCurrentPassword(password);
  }

  @override
  void updatePassword(String password) {
    provider.updatePassword(password);
  }
}
