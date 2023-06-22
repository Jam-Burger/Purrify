import 'package:flutter/material.dart';
import 'package:purrify/pages/login_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    waitFor2seconds(context);
    return Container(
      color: Colors.blueAccent,
    );
  }

  Future<void> waitFor2seconds(context) async {
    await Future.delayed(
      const Duration(seconds: 1),
      () => {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        )
      },
    );
  }
}
