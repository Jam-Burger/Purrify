import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:purrify/config.dart';
import 'package:purrify/models/artist.dart';
import 'package:purrify/utilities/access_token_manager.dart';
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
                  String accessToken = await AccessTokenManager.getToken();
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
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  String token = await AccessTokenManager.getToken();
                  Response response = await get(
                      Uri.parse(
                          'https://api.spotify.com/v1/artists/0TnOYISbd1XYRBk9myaseg'),
                      headers: {'Authorization': 'Bearer $token'});
                  Map<String, dynamic> data = json.decode(response.body);

                  Artist artist = Artist.fromJson(data);
                  setState(() {
                    _bodyText = artist.images.toString();
                  });
                },
              ),
            ],
          ),
          Text(
            _bodyText,
            overflow: TextOverflow.fade,
            maxLines: 20,
          ),
        ],
      ),
    );
  }
}
