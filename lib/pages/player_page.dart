import 'package:flutter/material.dart';
import 'package:purrify/utilities/functions.dart';
import 'package:spotify_sdk/models/player_options.dart' as player_options;
import 'package:spotify_sdk/spotify_sdk.dart';

class PlayerPage extends StatefulWidget {
  final String uri;
  final Future<String> lyricsFuture;

  const PlayerPage({super.key, required this.uri, required this.lyricsFuture});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late String _currentUri;
  bool _playing = true;
  bool _isShuffling = false;
  player_options.RepeatMode _repeatMode = player_options.RepeatMode.off;
  String _lyrics = '';

  @override
  void initState() {
    super.initState();
    _currentUri = widget.uri;
    SpotifySdk.subscribePlayerState().listen((state) {
      setState(() {
        _currentUri = state.track!.uri;
        _playing = !state.isPaused;
        _isShuffling = state.playbackOptions.isShuffling;
        _repeatMode = state.playbackOptions.repeatMode;
      });
      log(_repeatMode);
    });

    widget.lyricsFuture.then((value) {
      setState(() {
        _lyrics = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.teal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: ListView(children: [Text(_lyrics)])),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isShuffling = !_isShuffling;
                      });
                      SpotifySdk.toggleShuffle();
                    },
                    icon: _isShuffling
                        ? const Icon(Icons.shuffle_on_outlined)
                        : const Icon(Icons.shuffle),
                  ),
                  IconButton(
                    onPressed: () {
                      SpotifySdk.skipPrevious();
                    },
                    icon: const Icon(Icons.skip_previous),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (_playing) {
                        SpotifySdk.pause();
                      } else {
                        SpotifySdk.resume();
                      }
                      setState(() {
                        _playing = !_playing;
                      });
                    },
                    icon: _playing
                        ? const Icon(Icons.pause)
                        : const Icon(Icons.play_arrow),
                  ),
                  IconButton(
                    onPressed: () {
                      SpotifySdk.skipNext();
                    },
                    icon: const Icon(Icons.skip_next),
                  ),
                  IconButton(
                    onPressed: () {
                      switch (_repeatMode) {
                        case player_options.RepeatMode.off:
                          SpotifySdk.setRepeatMode(
                              repeatMode: RepeatMode.context);
                          setState(() {
                            _repeatMode = player_options.RepeatMode.context;
                          });
                          break;
                        case player_options.RepeatMode.context:
                          SpotifySdk.setRepeatMode(
                              repeatMode: RepeatMode.track);
                          setState(() {
                            _repeatMode = player_options.RepeatMode.track;
                          });
                          break;
                        case player_options.RepeatMode.track:
                          SpotifySdk.setRepeatMode(repeatMode: RepeatMode.off);
                          setState(() {
                            _repeatMode = player_options.RepeatMode.off;
                          });
                          break;
                      }
                    },
                    icon: _repeatMode == player_options.RepeatMode.off
                        ? const Icon(Icons.repeat)
                        : _repeatMode == player_options.RepeatMode.context
                            ? const Icon(Icons.repeat_on_outlined)
                            : const Icon(Icons.repeat_one_on_outlined),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
