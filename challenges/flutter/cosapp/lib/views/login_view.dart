import 'package:cosapp/constants/routes.dart';
import 'package:cosapp/widgets/dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
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
                          final userCredential =
                              await _auth.signInWithEmailAndPassword(
                                  email: email, password: password);
                          devtools.log('USER CREDENTIAL: $userCredential');
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            profileRoute,
                            (route) => false,
                          );
                        } on FirebaseException catch (e) {
                          if (e.code == 'invalid-email') {
                            await showErrorDialog(context, e.code);
                          } else if (e.code == 'user-not-found') {
                            await showErrorDialog(context, 'User not found');
                          } else if (e.code == 'wrong-password') {
                            await showErrorDialog(context, 'Wrong credentials');
                          } else {
                            await showErrorDialog(context, 'Error: %{e.code}');
                          }
                        } catch(e) {
                            await showErrorDialog(context, e.toString());
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
