import 'package:flutter/material.dart';

class CommonInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const CommonInputField({super.key, 
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}
