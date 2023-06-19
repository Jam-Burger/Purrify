import 'package:flutter/material.dart';
import 'package:purrify/utilities/routes.dart';

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
        Navigator.of(context).pushNamedAndRemoveUntil(
          loginRoute,
          (route) => false,
        )
      },
    );
  }
}
