class Constants {
  static const String prefixDevAppKey = "ak_dev_";
  static const String prefixStageAppKey = "ak_test_";
  static const String prefixLiveAppKey = "ak_live_";

  static const String devWidgetUrl = "https://dev-widget.wepin.io"; // dev
  static const String stageWidgetUrl = "https://stage-widget.wepin.io"; // stage
  static const String prodWidgetUrl = "https://widget.wepin.io"; // prod

  static const String devSdkFacadeUrl = "https://dev-sdk.wepin.io"; // dev
  static const String stageSdkFacadeUrl = "https://stage-sdk.wepin.io"; // stage
  static const String prodSdkFacadeUrl = "https://sdk.wepin.io"; // prod

  //static const String widgetInterfaceVersion = '1';
  static const String sdkVersion = '0.0.4';
  static const int androidPlatformNum = 2;
  static const int iosPlatformNum = 3;

  static const String cookieName = "wepin:widget"; // for SecureStorage
  static const String wepinTokenKeyName = "keyWepinToken"; // for SecureStorage
}
