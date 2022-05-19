import 'package:cosapp/services/auth/auth_user.dart';

// This class is giving us an interface for any authentication provider that we might want to work with. 
// For this challenge I will use only Firebase though. 

abstract class AuthProvider {
  AuthUser? get currentUser;

  Future<void> initialize();

  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset({required String toEmail});

  Future<void> logOut();
}
