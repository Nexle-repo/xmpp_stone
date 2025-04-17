class LinkMessage {
  final String? category;
  final bool? inApp;
  final String fullUrl;
  final String? logo;
  final String? title;
  final String? description;
  final String? url;

  LinkMessage({
    required this.fullUrl,
    this.url,
    this.category,
    this.inApp,
    this.title,
    this.description,
    this.logo,
  });
}
