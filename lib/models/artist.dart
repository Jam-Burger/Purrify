import 'package:purrify/models/image.dart';

class Artist {
  String _id, _name, _uri;
  Uri _externalUrl, _href;
  int _followers, _popularity;
  List<String> _genres;
  List<Image> _images;

  Artist(
    this._id,
    this._name,
    this._uri,
    this._externalUrl,
    this._href,
    this._followers,
    this._popularity,
    this._genres,
    this._images,
  );

  factory Artist.fromJson(Map<String, dynamic> json) => Artist(
        json['id'] as String,
        json['name'] as String,
        json['uri'] as String,
        Uri.parse((json['external_urls'] as Map<String, dynamic>)['spotify']
            as String),
        Uri.parse(json['href'] as String),
        (json['followers'] as Map<String, dynamic>)['total'] as int,
        json['popularity'] as int,
        (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
        (json['images'] as List<dynamic>)
            .map((e) => Image.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  List<Image> get images => _images;

  List<String> get genres => _genres;

  get popularity => _popularity;

  int get followers => _followers;

  get href => _href;

  Uri get externalUrl => _externalUrl;

  get uri => _uri;

  get name => _name;

  String get id => _id;
}
