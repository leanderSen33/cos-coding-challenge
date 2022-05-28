import 'package:flutter/material.dart';

class ChangePhotoTextButton extends StatelessWidget {
  const ChangePhotoTextButton({
    Key? key,
    required this.save,
    required this.activateButton,
  }) : super(key: key);

  final VoidCallback save;
  final bool activateButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 33,
      child: TextButton(
        child: const Text(
          'Change photo',
        ),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: Colors.grey,
        ),
        onPressed: activateButton == true ? save : null,
      ),
    );
  }
}

