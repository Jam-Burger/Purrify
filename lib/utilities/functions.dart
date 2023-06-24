import 'dart:developer' as devtools;

import 'package:flutter/material.dart';

void log(Object? message) {
  devtools.log(message?.toString() ?? 'null');
}

String millisToMinSec(int millis) {
  Duration d = Duration(milliseconds: millis);
  return d.toString().substring(2, 7);
}

void showSnackBar({required context, required message, duration = 2}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    margin: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 10,
    ),
    backgroundColor: Colors.grey,
    content: Text(message.toString()),
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: duration),
  ));
}
