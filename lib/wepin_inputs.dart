class WepinOptions {
  final String _appId;
  final String _appKey;
  final WidgetAttributes _widgetAttributes;

  WepinOptions(this._appId, this._appKey, this._widgetAttributes);

  WidgetAttributes get widgetAttributes => _widgetAttributes;

  String get appKey => _appKey;

  String get appId => _appId;

  Map<String, dynamic> toJson() {
    return {
      'appId': _appId,
      'appKey': _appKey,
      'attributes': _widgetAttributes.toJson()
    };
  }
}

class WidgetAttributes {
  final String _defaultLanguage;
  final String _defaultCurrency;

  WidgetAttributes(this._defaultLanguage, this._defaultCurrency);

  String get defaultCurrency => _defaultCurrency;

  String get defaultLanguage => _defaultLanguage;

  Map<String, dynamic> toJson() {
    return {
      'defaultCurrency': _defaultCurrency,
      'defaultLanguage': _defaultLanguage
    };
  }
}
