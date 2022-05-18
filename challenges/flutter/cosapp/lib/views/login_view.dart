import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

class LogInView extends StatefulWidget {
  const LogInView({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _email.text = 'test@cosie.com';
    _password = TextEditingController();
    _password.text = '123abctesting';
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login screen'),
      ),
      body: Center(
        child: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(controller: _email),
                    TextField(controller: _password),
                    TextButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        try {
                          final _auth = FirebaseAuth.instance;
                          final userCredential = await _auth
                              .signInWithEmailAndPassword(
                                  email: email, password: password);
                          print('USER CREDENTIAL: $userCredential');
                          // these two are basically the same except user credential has more info on it.
                          print('CURRENT USER: ${_auth.currentUser}');
                          Navigator.pushNamed(context, '/profilepage');
                        } on FirebaseException catch (e) {
                          //TODO: Add dialog alerts
                          if (e.code == 'invalid-email') {
                            print('You\'ve inserted an invalid email');
                          } else if (e.code == 'user-not-found') {
                            print('User not found');
                          } else if (e.code == 'wrong-password') {
                            print('Wrong password!');
                          }
                        }
                      },
                      child: const Text('Login'),
                    )
                  ],
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
