import 'package:flutter/material.dart';
import 'package:purrify/config.dart';
import 'package:purrify/pages/main_page.dart';
import 'package:purrify/utilities/functions.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    SpotifySdk.connectToSpotifyRemote(
      clientId: clientId,
      redirectUrl: redirectUrl,
    ).then((value) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainPage()),
        (route) => false,
      );
    }).catchError((e) {
      log(e.toString());
    });

    return Container(
      color: Colors.blueAccent,
    );
  }
}
