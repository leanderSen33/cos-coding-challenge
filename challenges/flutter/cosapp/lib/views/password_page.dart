import 'package:flutter/material.dart';

import '../services/auth/auth_service.dart';
import '../services/sorage/storage_service.dart';
import '../widgets/custom_fields.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PasswordPage(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final storage = StorageService();
  final _auth = AuthService.firebase();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _checkCurrentPasswordValid = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF464A56),
        body: Column(
          children: [
            IconButton(
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // const SizedBox(height: 10),
                    const Text(
                      "Change password",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      title: 'password',
                      textController: _passwordController,
                      isObscure: false,
                      errorText: "Please double check your current password",
                      checkCurrentPasswordValid: _checkCurrentPasswordValid,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      title: 'new password',
                      textController: _newPasswordController,
                      isObscure: true,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      title: 'repeat password',
                      textController: _repeatPasswordController,
                      isObscure: true,
                      validator: (value) {
                        return _newPasswordController.text == value
                            ? null
                            : "Please validate your entered password";
                      },
                    ),
                    TextButton(
                      child: const Text("Save password changes"),
                      onPressed: () async {
                        _checkCurrentPasswordValid = await _auth
                            .validateCurrentPassword(_passwordController.text);
                        setState(() {});
                        if (_formKey.currentState!.validate() &&
                            _checkCurrentPasswordValid) {
                          _auth.updatePassword(_newPasswordController.text);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
