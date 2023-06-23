import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFieldTemplate extends StatelessWidget {
  final TextEditingController _controller;
  final String _hintText;
  final void Function(String)? _onChanged;
  final bool _isPassword;

  const TextFieldTemplate({
    super.key,
    required TextEditingController controller,
    String hintText = "",
    void Function(String)? onChanged,
    bool isPassword = false,
  })  : _onChanged = onChanged,
        _isPassword = isPassword,
        _hintText = hintText,
        _controller = controller;

  void _onChangedText(String text) {
    if (_onChanged != null) _onChanged!(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        onChanged: _onChangedText,
        obscureText: _isPassword,
        controller: _controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          hoverColor: Colors.black,
          filled: false,
          fillColor: Colors.white10,
          hintText: _hintText,
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
