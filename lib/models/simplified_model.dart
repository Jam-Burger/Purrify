class SimplifiedModel {
  String _id, _name, _uri;
  Uri _externalUrl, _href;

  SimplifiedModel(
      this._id, this._name, this._uri, this._externalUrl, this._href);

  factory SimplifiedModel.fromJson(Map<String, dynamic> json) =>
      SimplifiedModel(
        json['id'] as String,
        json['name'] as String,
        json['uri'] as String,
        Uri.parse((json['external_urls'] as Map<String, dynamic>)['spotify']
            as String),
        Uri.parse(json['href'] as String),
      );

  @override
  String toString() {
    return '\nid: $_id\nname: $_name\nuri: $_uri\nexternal url: $_externalUrl\nhref: $_href\n';
  }
}
