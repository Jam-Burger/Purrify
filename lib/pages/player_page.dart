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
  StreamSubscription<PlayerState>? _streamSubscription;
  String _currentUri = '';
  bool _isPlaying = false;
  bool _isShuffling = false;
  static const refreshDelta = 10;
  static const trackTimeOffset = 40;

  player_options.RepeatMode _repeatMode = player_options.RepeatMode.off;
  Map<int, String> _lyrics = <int, String>{};
  int _currentLyricsIndex = 0;
  late int _currentTrackTime;
  late int _currentTrackLength;

  late final ItemScrollController _lyricsScrollController;
  StreamController<String>? _lyricsStreamController;
  StreamSubscription<String>? _lyricsStreamSubscription;
  Timer? _timer;
  late int lastTrackUpdateTime;

  @override
  void initState() {
    super.initState();
    SpotifySdk.getPlayerState().then((state) {
      if (state == null || state.track == null) return;
      if (mounted) {
        setState(() {
          _currentUri = state.track!.uri;
          _isShuffling = state.playbackOptions.isShuffling;
          _repeatMode = state.playbackOptions.repeatMode;
          _isPlaying = !state.isPaused;
          _currentTrackTime = state.playbackPosition + trackTimeOffset;
          _currentTrackLength = state.track!.duration;
          lastTrackUpdateTime = DateTime.now().millisecondsSinceEpoch;
        });
      }
      loadLyrics(state.track!.uri.split(':')[2]);
      synchronizeLyrics();
    });

    _streamSubscription = SpotifySdk.subscribePlayerState().listen((state) {
      setState(() {
        _currentTrackTime = state.playbackPosition + trackTimeOffset;
        _currentTrackLength = state.track!.duration;
        lastTrackUpdateTime = DateTime.now().millisecondsSinceEpoch;
        if (_lyrics.isNotEmpty) {
          _currentLyricsIndex = _lyrics.keys
              .toList()
              .indexWhere((time) => time >= _currentTrackTime);
        }
        scrollToCurrentLyrics();
      });

      if (state.track != null) {
        if (state.track!.uri != _currentUri) {
          if (mounted) {
            setState(() {
              _lyrics = {};
              _currentUri = state.track!.uri;
            });
          }
          loadLyrics(state.track!.uri.split(':')[2]);
          synchronizeLyrics();
        }
      }
      if (mounted) {
        setState(() {
          _isPlaying = !state.isPaused;
          _isShuffling = state.playbackOptions.isShuffling;
          _repeatMode = state.playbackOptions.repeatMode;
        });
      }
      log('state changed $_currentUri');
    });

    _lyricsScrollController = ItemScrollController();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _lyricsStreamSubscription?.cancel();
    _timer?.cancel();
    _lyricsStreamController?.close();
    super.dispose();
  }

  void loadLyrics(String trackId) async {
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

    setState(() {
      _currentLyricsIndex =
          _lyrics.keys.toList().indexWhere((time) => time >= _currentTrackTime);
    });
    if (_currentLyricsIndex == -1) {
      _lyricsScrollController.jumpTo(index: 0, alignment: .6);
    } else {
      _lyricsScrollController.jumpTo(index: _currentLyricsIndex, alignment: .5);
    }
  }

  void synchronizeLyrics() {
    _lyricsStreamController?.close();
    _lyricsStreamSubscription?.cancel();
    _timer?.cancel();

    _lyricsStreamController = StreamController();
    _lyricsStreamSubscription = _lyricsStreamController?.stream.listen((event) {
      log(event);
      scrollToCurrentLyrics();
    });

    _timer =
        Timer.periodic(const Duration(milliseconds: refreshDelta), (timer) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      int timeDelta = currentTime - lastTrackUpdateTime;
      lastTrackUpdateTime = currentTime;

      if (_currentTrackTime + timeDelta >= _currentTrackLength) {
        _timer?.cancel();
        return;
      }
      if (_isPlaying) {
        setState(() {
          _currentTrackTime += timeDelta;
        });
      }

      if (_lyrics.isEmpty) return;
      if (_currentLyricsIndex >= _lyrics.length ||
          (_lyricsStreamController?.isClosed ?? false)) {
        _lyricsStreamController?.close();
        _lyricsStreamSubscription?.cancel();
        return;
      }

      if (_currentTrackTime >= _lyrics.keys.elementAt(_currentLyricsIndex)) {
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
          color: Colors.greenAccent,
          child: Column(
            children: [
              Expanded(
                child: ScrollablePositionedList.builder(
                  itemScrollController: _lyricsScrollController,
                  padding: const EdgeInsets.symmetric(vertical: 500),
                  itemCount: _lyrics.length,
                  itemBuilder: (context, index) {
                    if (index <= -1) return Container();
                    String text = _lyrics.values.elementAt(index);
                    // text.replaceAll(' (', '\n(');
                    return GestureDetector(
                      onTap: () {
                        int newTime = _lyrics.keys.elementAt(index);
                        SpotifySdk.seekTo(positionedMilliseconds: newTime);
                        setState(() {
                          _currentTrackTime = newTime;
                          _currentLyricsIndex = index;
                        });
                        scrollToCurrentLyrics();
                      },
                      child: Container(
                        color: index % 2 == 0 ? Colors.black12 : Colors.black26,
                        child: Text(
                          text,
                          style: index == _currentLyricsIndex - 1
                              ? const TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                )
                              : const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87,
                                ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      child: Row(
                        children: [
                          Text(millisToMinSec(_currentTrackTime)),
                          Expanded(
                            child: Slider(
                              value: _currentTrackTime.toDouble(),
                              min: 0,
                              max: _currentTrackLength.toDouble(),
                              label: 'trackTime',
                              thumbColor: Colors.purple,
                              activeColor: Colors.purpleAccent,
                              onChangeEnd: (value) {
                                SpotifySdk.seekTo(
                                    positionedMilliseconds: value.toInt());
                                setState(() {
                                  _currentTrackTime = value.toInt();
                                });
                              },
                              onChanged: (double value) {
                                setState(() {
                                  _currentTrackTime = value.toInt();
                                });
                              },
                            ),
                          ),
                          Text(millisToMinSec(_currentTrackLength)),
                        ],
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
                            if (_isPlaying) {
                              SpotifySdk.pause();
                            } else {
                              SpotifySdk.resume();
                            }
                            setState(() {
                              _isPlaying = !_isPlaying;
                            });
                          },
                          icon: _isPlaying
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
                                  _repeatMode =
                                      player_options.RepeatMode.context;
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
                                SpotifySdk.setRepeatMode(
                                    repeatMode: RepeatMode.off);
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
