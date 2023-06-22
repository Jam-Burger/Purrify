import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purrify/pages/start_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black12,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(MaterialApp(
    title: 'Flutter Demo',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: const ColorScheme.dark(),
      useMaterial3: true,
    ),
    home: const StartPage(),
  ));
}
