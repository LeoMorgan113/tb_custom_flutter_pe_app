abstract class ThingsboardAppConstants {
  static final thingsBoardApiEndpoint = 'http://10.7.3.172:8080/'; //mine
  // static final thingsBoardApiEndpoint = 'http://172.18.77.32:8080/'; // choco
  // static final thingsBoardApiEndpoint = 'http://login.darkblueiot.com/';
  // static final thingsBoardApiEndpoint = 'https://thingsboard.cloud/';
  static final thingsboardOAuth2CallbackUrlScheme =
      'org.thingsboard.pe.app.auth';

  /// Not for production (only for debugging)
  static final thingsboardOAuth2AppSecret = '';

  /// Not for production (only for debugging)
  static final thingsboardSignUpAppSecret = '';
}
