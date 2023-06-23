import 'package:purrify/models/image.dart';
import 'package:purrify/models/simplified_model.dart';

class Album {
  String _id, _name, _uri;
  Uri _externalUrl, _href;
  int _totalTracks, _popularity;
  List<String> _genres;
  List<Image> _images;
  DateTime _releaseDate;
  List<SimplifiedModel> _artists;
  List<SimplifiedModel> _tracks;

  Album(
    this._id,
    this._name,
    this._uri,
    this._externalUrl,
    this._href,
    this._totalTracks,
    this._popularity,
    this._genres,
    this._images,
    this._releaseDate,
    this._artists,
    this._tracks,
  );

  factory Album.fromJson(Map<String, dynamic> json) => Album(
        json['id'] as String,
        json['name'] as String,
        json['uri'] as String,
        Uri.parse((json['external_urls'] as Map<String, dynamic>)['spotify']
            as String),
        Uri.parse(json['href'] as String),
        json['total_tracks'] as int,
        json['popularity'] as int,
        (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
        (json['images'] as List<dynamic>)
            .map((e) => Image.fromJson(e as Map<String, dynamic>))
            .toList(),
        DateTime.parse(json['release_date'] as String),
        (json['artists'] as List<dynamic>)
            .map((e) => SimplifiedModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        ((json['tracks'] as Map<String, dynamic>)['items'] as List<dynamic>)
            .map((e) => SimplifiedModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  List<SimplifiedModel> get artists => _artists;

  DateTime get releaseDate => _releaseDate;

  List<Image> get images => _images;

  List<String> get genres => _genres;

  get popularity => _popularity;

  int get totalTracks => _totalTracks;

  get href => _href;

  Uri get externalUrl => _externalUrl;

  get uri => _uri;

  get name => _name;

  String get id => _id;

  List<SimplifiedModel> get tracks => _tracks;
}
