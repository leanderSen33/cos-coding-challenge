import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required TextEditingController textController,
    required this.title,
    required this.isObscure,
  })  : _inputText = textController,
        super(key: key);

  final TextEditingController _inputText;
  final String title;
  final bool isObscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: Colors.grey[200]),
      obscureText: isObscure,
      cursorHeight: 20,
      autofocus: false,
      controller: _inputText,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Colors.grey[500]),
        labelText: title,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
      ),
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    Key? key,
    required TextEditingController textController,
    required this.title,
    required this.isObscure,
    this.validator,
    this.checkCurrentPasswordValid = false,
    this.errorText,
  })  : _inputText = textController,
        super(key: key);

  final TextEditingController _inputText;
  final String title;
  final bool isObscure;
  final String? Function(String?)? validator;
  final bool checkCurrentPasswordValid;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      style: TextStyle(color: Colors.grey[200]),
      obscureText: isObscure,
      cursorHeight: 20,
      autofocus: false,
      controller: _inputText,
      decoration: InputDecoration(
        errorText: checkCurrentPasswordValid ? null : errorText,
        labelStyle: TextStyle(color: Colors.grey[500]),
        labelText: title,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
      ),
    );
  }
}
