class ListItem {
  String title, subTitle, uri;
  int popularity;
  Uri? imageUrl;

  ListItem({
    required this.title,
    required this.subTitle,
    required this.uri,
    required this.popularity,
    this.imageUrl,
  });
}
