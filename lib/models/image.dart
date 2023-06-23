class Image {
  final Uri _url;
  final int _width, _height;

  const Image(this._url, this._width, this._height);

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        Uri.parse(json['url'] as String),
        json['width'] as int,
        json['height'] as int,
      );

  Uri get url => _url;

  @override
  String toString() {
    return '\nurl: $_url\nwidth: $_width\nheight: $_height\n';
  }

  int get width => _width;

  get height => _height;
}
