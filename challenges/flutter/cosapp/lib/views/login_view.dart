import 'package:cosapp/constants/routes.dart';
import 'package:cosapp/services/auth/auth_exceptions.dart';
import 'package:cosapp/services/auth/auth_service.dart';
import 'package:cosapp/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

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
          future: AuthService.firebase().initialize(),
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
                          final userCredential =
                              await AuthService.firebase().logIn(
                            email: email,
                            password: password,
                          );
                          devtools.log(
                            'USER CREDENTIAL: ${userCredential.email}',
                          );
                          //TODO: CHeck out this guy because it's causing problems sometimes. 
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            profileRoute,
                            (route) => false,
                          );
                        } on UserNotFoundAuthException {
                          await showErrorDialog(
                            context,
                            'User not found',
                          );
                        } on WrongPasswordAuthException {
                          await showErrorDialog(
                            context,
                            'Wrong credentials',
                          );
                        } on GenericAuthException {
                          await showErrorDialog(
                            context,
                            'Authentication error',
                          );
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
