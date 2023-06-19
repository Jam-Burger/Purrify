import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purrify/pages/home_page.dart';
import 'package:purrify/pages/login_page.dart';
import 'package:purrify/pages/signin_page.dart';
import 'package:purrify/pages/start_page.dart';
import 'package:purrify/utilities/routes.dart';

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
    routes: {
      loginRoute: (context) => const LoginPage(),
      signinRoute: (context) => const SigninPage(),
      homeRoute: (context) => const HomePage(),
    },
    home: const StartPage(),
  ));
}
