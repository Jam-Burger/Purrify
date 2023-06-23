class Image {
  final Uri _url;
  final int _width, _height;

  const Image(this._url, this._width, this._height);

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        Uri.parse(json['url'] as String),
        json['width'] as int,
        json['height'] as int,
      );
  @override
  String toString() {
    return '\nurl: $_url\nwidth: $_width\nheight: $_height\n';
  }
}
