import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFieldTemplate extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final void Function(String)? onChanged;
  final bool isPassword;

  const TextFieldTemplate({
    super.key,
    required this.controller,
    this.hintText = "",
    this.onChanged,
    this.isPassword = false,
  });

  void _onChanged(String text) {
    if (onChanged != null) onChanged!(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        onChanged: _onChanged,
        obscureText: isPassword,
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          hoverColor: Colors.black,
          filled: false,
          fillColor: Colors.white10,
          hintText: hintText,
          hintStyle: GoogleFonts.arimo(
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}
