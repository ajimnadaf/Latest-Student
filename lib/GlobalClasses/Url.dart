class UrlUtils {
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;

    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return false;

    return (uri.scheme == 'http' || uri.scheme == 'https') &&
           uri.host.isNotEmpty;
  }
}