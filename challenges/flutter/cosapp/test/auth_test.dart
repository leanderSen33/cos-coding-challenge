// import 'package:cosapp/services/auth/auth_exceptions.dart';
// import 'package:cosapp/services/auth/auth_provider.dart';
// import 'package:cosapp/services/auth/auth_user.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:test/test.dart';

// void main() {
//   group('Mock Authentication', () {
//     final provider = MockAuthProvider();
//     test('Should not be initialized to begin with', () {
//       expect(provider.isInitialized, false);
//     });

//     test('Cannot log out if not initialized', () {
//       expect(
//         provider.logOut(),
//         throwsA(const TypeMatcher<NotInitializedException>()),
//       );
//     });

//     test('User should be null after initialization', () {
//       expect(provider.currentUser, null);
//     });

//     test('Should be able to log out and log in again', () async {
//       await provider.logOut();
//       await provider.logIn(
//         email: 'email',
//         password: 'password',
//       );
//       final user = provider.currentUser;
//       expect(user, isNotNull);
//     });
//   });
// }

// class NotInitializedException implements Exception {}

// class MockAuthProvider implements AuthProvider {
//   AuthUser? _user;
//   final _isInitialized = false;
//   bool get isInitialized => _isInitialized;

//   @override
//   AuthUser? get currentUser => _user;

//   @override
//   Future<AuthUser> logIn({
//     required String email,
//     required String password,
//   }) {
//     if (!isInitialized) throw NotInitializedException();
//     if (email == 'foo@bar.com') throw UserNotFoundAuthException();
//     if (password == 'foobar') throw WrongPasswordAuthException();
//     const user = AuthUser(
//       id: 'my_id',
//       email: 'foo@bar.com',
//       //  avatarUrl: '',
//     );
//     _user = user;
//     return Future.value(user);
//   }

//   @override
//   Future<void> logOut() async {
//     if (!isInitialized) throw NotInitializedException();
//     if (_user == null) throw UserNotFoundAuthException();
//     await Future.delayed(const Duration(seconds: 1));
//     _user = null;
//   }

//   @override
//   Future<void> sendPasswordReset({required String toEmail}) {
//     throw UnimplementedError();
//   }

//   @override
//   Stream<User?> authStateChanges() {
//     // TODO: implement authStateChanges
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> updatePassword(String password) {
//     // TODO: implement updatePassword
//     throw UnimplementedError();
//   }

//   @override
//   Future<bool> validateCurrentPassword(String password) {
//     // TODO: implement validateCurrentPassword
//     throw UnimplementedError();
//   }
// }
