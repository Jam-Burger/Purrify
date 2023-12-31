import 'dart:core';

import 'package:purrify/models/image.dart';
import 'package:purrify/models/simplified_model.dart';

class Track {
  String _id, _name, _uri;
  Uri _externalUrl, _href;
  Uri? _previewUrl;
  int _duration, _popularity;
  bool _explicit;
  DateTime? _releaseDate;
  SimplifiedModel _album;
  List<SimplifiedModel> _artists;
  List<Image> _images;

  Track(
    this._id,
    this._name,
    this._uri,
    this._externalUrl,
    this._href,
    this._previewUrl,
    this._popularity,
    this._duration,
    this._explicit,
    this._releaseDate,
    this._album,
    this._artists,
    this._images,
  );

  factory Track.fromJson(Map<String, dynamic> json) => Track(
        json['id'] as String,
        json['name'] as String,
        json['uri'] as String,
        Uri.parse((json['external_urls'] as Map<String, dynamic>)['spotify']
            as String),
        Uri.parse(json['href'] as String),
        (json['preview_url'] as String?) != null
            ? Uri.parse(json['preview_url'] as String)
            : null,
        json['popularity'] as int,
        json['duration_ms'] as int,
        json['explicit'] as bool,
        (json['release_date'] as String?) != null
            ? DateTime.parse(json['release_date'] as String)
            : null,
        SimplifiedModel.fromJson(json['album'] as Map<String, dynamic>),
        (json['artists'] as List<dynamic>)
            .map((e) => SimplifiedModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        ((json['album'] as Map<String, dynamic>)['images'] as List<dynamic>)
            .map((e) => Image.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  bool get explicit => _explicit;

  List<Image> get images => _images;

  List<SimplifiedModel> get artists => _artists;

  SimplifiedModel get album => _album;

  int get popularity => _popularity;

  int get duration => _duration;

  get previewUrl => _previewUrl;

  get href => _href;

  Uri get externalUrl => _externalUrl;

  get uri => _uri;

  get releaseDate => _releaseDate;

  get name => _name;

  String get id => _id;
}
