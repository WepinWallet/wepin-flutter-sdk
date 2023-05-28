import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wepin_flutter/model/wepin_manager_model.dart';
import 'package:wepin_flutter/wepin_flutter.dart';
import 'package:wepin_flutter/wepin_inputs.dart';
import 'package:wepin_flutter/wepin_outputs.dart';

class Wepin {
  WepinFlutter? _wepinFlutter;
  late WepinOptions _wepinOptions;
  late BuildContext _appContext;

  static final Wepin _instance = Wepin._internal();

  // singleton
  factory Wepin() => _instance;

  Wepin._internal() {
    if (kDebugMode) {
      print('wepin_internal');
    }
  }

  void initialize(BuildContext appContext, WepinOptions wepinOptions) {
    print('wepin_initialize');
    _appContext = appContext;
    _wepinOptions = wepinOptions;

    if (_wepinFlutter != null) {
      finalize();
    }

    showDialog(
        context: _appContext,
        builder: (context) {
          _wepinFlutter = WepinFlutter(wepinOptions, null, _appContext.widget);
          return _wepinFlutter!;
        });
  }

  void handleWepinLink(Uri linkUrl) {
    print('handleWepinLink');

    if (_wepinFlutter != null) {
      _wepinFlutter!.finalize();
    }

    showDialog(
        context: _appContext,
        builder: (context) {
          _wepinFlutter =
              WepinFlutter(_wepinOptions, linkUrl, _appContext.widget);
          return _wepinFlutter!;
        });
  }

  bool isInitialized() {
    print('wepin_isInitialized');
    return WepinManagerModel().getInitialized();
  }

  void openWidget() {
    print('wepin_openWidget');
    if (!isInitialized()) {
      print('widget is not initialized');
      return;
    }
    showDialog(
        context: _appContext,
        builder: (context) {
          return _wepinFlutter!;
        });
  }

  void closeWidget() {
    print('wepin_closeWidget');
    if (!isInitialized()) {
      print('widget is not initialized');
      return;
    }

    if (Navigator.canPop(_appContext)) {
      print('return_to_app');
      Navigator.pop(_appContext);
    }
  }

  List<Account>? getAccounts() {
    print('wepin_getAccounts');
    if (!isInitialized()) {
      print('widget is not initialized');
      return null;
    }
    return WepinManagerModel().getAccounts();
  }

  void finalize() {
    print('wepin_finalize');
    WepinManagerModel().setInitialized(false);
    WepinManagerModel().setAccounts(null);
    if (_wepinFlutter != null) {
      _wepinFlutter!.finalize();
      _wepinFlutter = null;
    }
  }
}
