import 'package:cosapp/services/auth/auth_exceptions.dart';
import 'package:cosapp/services/auth/auth_service.dart';
import 'package:cosapp/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import '../widgets/custom_text_field.dart';

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
    _password = TextEditingController();
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF464A56),
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Login'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomTextField(
                  textController: _email,
                  isObscure: false,
                  title: 'email',
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  textController: _password,
                  isObscure: true,
                  title: 'password',
                ),
                SaveButton(email: _email, password: _password)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  const SaveButton({
    Key? key,
    required TextEditingController email,
    required TextEditingController password,
  })  : _email = email,
        _password = password,
        super(key: key);

  final TextEditingController _email;
  final TextEditingController _password;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final email = _email.text;
        final password = _password.text;
        try {
          final userCredential = await AuthService.firebase().logIn(
            email: email,
            password: password,
          );
          devtools.log(
            'USER CREDENTIAL: ${userCredential.email}',
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
    );
  }
}
