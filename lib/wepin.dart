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
    if (kDebugMode) {
      print('wepin_initialize');
    }
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
    if (kDebugMode) {
      print('handleWepinLink');
    }

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
    if (kDebugMode) {
      print('wepin_isInitialized');
    }
    return WepinManagerModel().getInitialized();
  }

  void openWidget() {
    if (kDebugMode) {
      print('wepin_openWidget');
    }
    if (!isInitialized()) {
      if (kDebugMode) {
        print('widget is not initialized');
      }
      return;
    }
    showDialog(
        context: _appContext,
        builder: (context) {
          return _wepinFlutter!;
        });
  }

  void closeWidget() {
    if (kDebugMode) {
      print('wepin_closeWidget');
    }
    if (!isInitialized()) {
      if (kDebugMode) {
        print('widget is not initialized');
      }
      return;
    }

    if (Navigator.canPop(_appContext)) {
      if (kDebugMode) {
        print('return_to_app');
      }
      Navigator.pop(_appContext);
    }
  }

  List<Account>? getAccounts() {
    if (kDebugMode) {
      print('wepin_getAccounts');
    }
    if (!isInitialized()) {
      if (kDebugMode) {
        print('widget is not initialized');
      }
      return null;
    }
    return WepinManagerModel().getAccounts();
  }

  void finalize() {
    if (kDebugMode) {
      print('wepin_finalize');
    }
    WepinManagerModel().setInitialized(false);
    WepinManagerModel().setAccounts(null);
    if (_wepinFlutter != null) {
      _wepinFlutter!.finalize();
      _wepinFlutter = null;
    }
  }
}
