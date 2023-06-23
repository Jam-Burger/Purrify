import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purrify/config.dart';
import 'package:purrify/utilities/functions.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class ExperimentsPage extends StatefulWidget {
  const ExperimentsPage({super.key});

  @override
  State<ExperimentsPage> createState() => _ExperimentsPageState();
}

class _ExperimentsPageState extends State<ExperimentsPage> {
  String _bodyText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.cast_connected),
            onPressed: () async {
              SpotifySdk.connectToSpotifyRemote(
                  clientId: clientId, redirectUrl: redirectUrl);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              SpotifySdk.disconnect()
                  .then((value) => {
                        if (value)
                          log('logged out successfully')
                        else
                          log("couldn't log out")
                      })
                  .catchError((error) => {log(error.toString())});
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(
            color: Colors.grey,
            thickness: .1,
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.generating_tokens),
                onPressed: () async {
                  final accessToken = await SpotifySdk.getAccessToken(
                      clientId: clientId, redirectUrl: redirectUrl);
                  log(accessToken);
                  Clipboard.setData(ClipboardData(text: accessToken));
                },
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () async {
                  SpotifySdk.resume();
                },
              ),
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: () async {
                  SpotifySdk.pause();
                },
              ),
            ],
          ),
          Text(_bodyText),
        ],
      ),
    );
  }
}
