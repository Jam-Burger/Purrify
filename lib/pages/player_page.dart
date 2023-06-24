import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:purrify/config.dart';
import 'package:purrify/utilities/functions.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:spotify_sdk/models/player_options.dart' as player_options;
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final StreamSubscription<PlayerState> _streamSubscription;
  String _currentUri = '';
  bool _playing = true;
  bool _isShuffling = false;

  player_options.RepeatMode _repeatMode = player_options.RepeatMode.off;
  Map<int, String> _lyrics = <int, String>{};
  int _currentLyricsIndex = 0;

  late final ItemScrollController _lyricsScrollController;
  StreamController<String>? _lyricsStreamController;
  StreamSubscription<String>? _lyricsStreamSubscription;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SpotifySdk.getPlayerState().then((state) {
      if (state == null || state.track == null) return;
      if (mounted) {
        setState(() {
          _currentUri = state.track!.uri;
        });
      }
      loadLyrics(state.track!.uri.split(':')[2], state.playbackPosition);
    });

    _streamSubscription = SpotifySdk.subscribePlayerState().listen((state) {
      if (state.track != null) {
        if (state.track!.uri != _currentUri) {
          if (mounted) {
            setState(() {
              _lyrics = {};
              _currentUri = state.track!.uri;
            });
          }

          loadLyrics(state.track!.uri.split(':')[2], state.playbackPosition);
        }
      }
      if (mounted) {
        setState(() {
          _playing = !state.isPaused;
          _isShuffling = state.playbackOptions.isShuffling;
          _repeatMode = state.playbackOptions.repeatMode;
        });
      }
      log(_currentUri);
    });

    _lyricsScrollController = ItemScrollController();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _lyricsStreamSubscription?.cancel();
    _timer?.cancel();
    _lyricsStreamController?.close();
    super.dispose();
  }

  void loadLyrics(String trackId, int trackPosition) async {
    _lyricsStreamController?.close();
    _lyricsStreamSubscription?.cancel();
    _timer?.cancel();

    final old = DateTime.now().millisecondsSinceEpoch;

    String lyricsUri = '$lyricsApiUrl/?trackid=$trackId'; //&format=lrc
    final response = await get(Uri.parse(lyricsUri));
    Map<String, dynamic> data = json.decode(response.body);

    if (data['error']) {
      log('error while loading lyrics');
      return;
    }
    final lyrics = <int, String>{};
    for (final e in (data['lines'])) {
      lyrics[int.parse(e['startTimeMs'])] = e['words'];
    }
    if (mounted) {
      setState(() {
        _lyrics = lyrics;
      });
    }

    int startTime = DateTime.now().millisecondsSinceEpoch;
    int lyricsLoadGap = startTime - old;
    int currentTrackPosition = trackPosition + lyricsLoadGap;

    setState(() {
      _currentLyricsIndex = _lyrics.keys
          .toList()
          .indexWhere((time) => time >= currentTrackPosition);
    });
    if (_currentLyricsIndex == -1) {
      _lyricsScrollController.jumpTo(index: 0, alignment: .6);
    } else {
      _lyricsScrollController.jumpTo(index: _currentLyricsIndex, alignment: .5);
    }

    synchronizeLyrics(currentTrackPosition);
  }

  void synchronizeLyrics(int currentTrackPosition) {
    int startTime = DateTime.now().millisecondsSinceEpoch;

    _lyricsStreamController = StreamController();
    _lyricsStreamSubscription = _lyricsStreamController?.stream.listen((event) {
      log(event);
      scrollToCurrentLyrics();
    });

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      int elapsedTime = DateTime.now().millisecondsSinceEpoch -
          startTime +
          currentTrackPosition;

      if (_currentLyricsIndex >= _lyrics.length) {
        _lyricsStreamController?.close();
        _lyricsStreamSubscription?.cancel();
        _timer?.cancel();
        setState(() {
          _lyrics = {};
        });
        return;
      }

      if (elapsedTime >= _lyrics.keys.elementAt(_currentLyricsIndex)) {
        _lyricsStreamController
            ?.add(_lyrics.values.elementAt(_currentLyricsIndex));
        setState(() {
          _currentLyricsIndex++;
        });
      }
    });
  }

  void scrollToCurrentLyrics() {
    if (_currentLyricsIndex >= 0) {
      _lyricsScrollController.scrollTo(
        index: _currentLyricsIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.teal,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ScrollablePositionedList.builder(
                    itemScrollController: _lyricsScrollController,
                    padding: const EdgeInsets.symmetric(vertical: 500),
                    itemCount: _lyrics.length,
                    itemBuilder: (context, index) {
                      if (index <= -1) return Container();
                      String text = _lyrics.values
                          .elementAt(index)
                          .replaceAll(' (', '\n(');
                      return Container(
                        color: index % 2 == 0 ? Colors.black12 : Colors.black26,
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize:
                                index == _currentLyricsIndex - 1 ? 30 : 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ),
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
