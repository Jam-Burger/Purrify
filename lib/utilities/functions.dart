import 'dart:developer' as devtools;

import 'package:flutter/material.dart';

void log(String? message) {
  devtools.log(message ?? 'null');
}

void showSnackBar({required context, required message, duration = 2}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    margin: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 10,
    ),
    backgroundColor: Colors.grey,
    content: Text(message),
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: duration),
  ));
}
