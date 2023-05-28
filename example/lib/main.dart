import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:wepin_flutter/wepin.dart';
import 'package:wepin_flutter/wepin_delegate.dart';
import 'package:wepin_flutter/wepin_inputs.dart';
import 'package:wepin_flutter/wepin_outputs.dart';

void main() => runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SampleApp(),
    ));

class SampleApp extends StatefulWidget with WepinDelegate {
  SampleApp({super.key});
  late Wepin _wepin;

  @override
  _SampleApp createState() => _SampleApp();

  @override
  void onWepinError(String errMsg) {
    // TODO: implement onWepinError
    print('onWepinError : $errMsg');
  }

  @override
  void onAccountSet() {
    // TODO: implement onAccountSet
    print('onAccountSet');
    List<Account>? accounts = _wepin.getAccounts();
    if (accounts == null) {
      print('accounts is null');
      return;
    }
    for (var account in accounts!) {
      print('netwrok : ${account.network}');
      print('address : ${account.address}');
    }
  }
}

class _SampleApp extends State<SampleApp> {
  StreamSubscription? _sub;
  final String _appId = 'test_app_id';
  final String _appSdkKey = 'test_app_key';

  @override
  void initState() {
    print('initState');
    super.initState();

    widget._wepin = Wepin();
    _handleDeepLink(); // Noti : 딥링크 처리함수 추가
  }

  /// Handle incoming links - the ones that the app will recieve from the OS
  /// while already started.
  /// Noti : 딥링크 받는 부분
  void _handleDeepLink() {
    print('_handleDeepLink');
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        print('got_uri: $uri');
        widget._wepin.handleWepinLink(uri!);
      }, onError: (Object err) {
        if (!mounted) return;
        print('got_err: $err');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Wepin Flutter Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () => _initialize(context),
                  child: const Text('initialize')),
              ElevatedButton(
                  onPressed: _isInitialized,
                  child: const Text('is_initialized')),
              ElevatedButton(
                  onPressed: _openWidget, child: const Text('open_widget')),
              ElevatedButton(
                  onPressed: _closeWidget, child: const Text('close_widget')),
              ElevatedButton(
                  onPressed: _getAccounts, child: const Text('get_accounts')),
              ElevatedButton(
                  onPressed: _finalize, child: const Text('finalize')),
            ],
          ),
        ),
      ),
    );
  }

  void _initialize(BuildContext context) {
    print('_initialize');
    if (widget._wepin.isInitialized()) {
      _showToast('Already initialized');
      return;
    }
    WidgetAttributes widgetAttributes = WidgetAttributes('ko', 'krw');
    WepinOptions wepinOptions =
        WepinOptions(_appId, _appSdkKey, widgetAttributes);
    widget._wepin.initialize(context, wepinOptions);
  }

  void _isInitialized() {
    print('_isInitialized');
    bool result = widget._wepin.isInitialized();
    _showToast('isIntialized : $result');
  }

  void _openWidget() {
    print('_openWidget');
    if (!widget._wepin.isInitialized()) {
      _showToast('Wepin is not initialized');
      return;
    }
    widget._wepin.openWidget();
  }

  void _closeWidget() {
    print('_closeWidget');
    if (!widget._wepin.isInitialized()) {
      _showToast('Wepin is not initialized');
      return;
    }
    widget._wepin.closeWidget();
  }

  void _getAccounts() {
    List<Account>? accounts;
    print('_getAccounts');
    if (!widget._wepin.isInitialized()) {
      _showToast('Wepin is not initialized');
      return;
    }
    accounts = widget._wepin.getAccounts();
    if (accounts == null) {
      print('accounts is null');
      _showToast('accounts is null');
      return;
    }
    for (var account in accounts!) {
      print('network : ${account.network}');
      print('address : ${account.address}');
    }
  }

  void _finalize() {
    print('_finalize');
    widget._wepin.finalize();
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        fontSize: 15.0,
        textColor: Colors.black,
        toastLength: Toast.LENGTH_SHORT);
  }
}
