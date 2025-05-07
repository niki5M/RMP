import 'package:flutter/material.dart';
import 'package:testik2/core/theme/colors.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({super.key, required this.buttonText, required this.onPressed});
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(395, 55),
        side: BorderSide(
          color: Palete.primaryOrange,
          width: 2,
        ),
        backgroundColor: Color(0xffF2F2F2),
        foregroundColor: Palete.primaryOrange,
      ),
    );

  }
}
