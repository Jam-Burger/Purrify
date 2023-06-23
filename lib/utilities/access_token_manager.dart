import 'package:purrify/config.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class AccessTokenManager {
  static String _accessToken = '';
  static DateTime _lastRefreshTime = DateTime.now();

  static Future<String> getToken() async {
    if (_accessToken.isEmpty ||
        DateTime.now().difference(_lastRefreshTime).inMinutes >= 50) {
      _accessToken = await SpotifySdk.getAccessToken(
        clientId: clientId,
        redirectUrl: redirectUrl,
      );
      _lastRefreshTime = DateTime.now();
    }
    return _accessToken;
  }
}
