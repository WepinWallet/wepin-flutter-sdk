import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:wepin_flutter/wepin.dart';
import 'package:wepin_flutter/wepin_inputs.dart';
import 'package:wepin_flutter/wepin_outputs.dart';

late Wepin _wepin;
void main() => runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SampleApp(),
    ));

class SampleApp extends StatefulWidget {
  SampleApp({super.key});

  @override
  _SampleApp createState() => _SampleApp();
}

class _SampleApp extends State<SampleApp> {
  StreamSubscription? _sub;
  final String _appId = '88889999000000000000000000000000';
  final String _appSdkKey = 'test_app_key';
  final String _testPrivKey = 'PrivateKey for signnig idToken';
  final String _testIdToken = 'idToken for loginWithExternalToken';
  String _testSignedIdToken = '';
  String _wepinResult = '';

  @override
  void initState() {
    if (kDebugMode) {
      print('initState');
    }
    super.initState();

    _wepin = Wepin();
    _handleDeepLink(); // Noti : 딥링크 처리함수 추가
  }

  /// Handle incoming links - the ones that the app will recieve from the OS
  /// while already started.
  /// Noti : 딥링크 받는 부분
  void _handleDeepLink() {
    if (kDebugMode) {
      print('_handleDeepLink');
    }
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        if (kDebugMode) {
          print('got_uri: $uri');
        }
        _wepin.handleWepinLink(uri!);
      }, onError: (Object err) {
        if (!mounted) return;
        if (kDebugMode) {
          print('got_err: $err');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('build');
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Wepin Flutter Example',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 30)),
                        onPressed: () => _initialize(context),
                        child: const Text('initialize'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 30)),
                        onPressed: _isInitialized,
                        child: const Text('is_initialized'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 30)),
                        onPressed: _getStatus,
                        child: const Text('get_status'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 30)),
                        onPressed: _login,
                        child: const Text('login'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 30)),
                        onPressed: _openWidget,
                        child: const Text('open_widget'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 30)),
                        onPressed: _closeWidget,
                        child: const Text('close_widget'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 30)),
                        onPressed: _getAccounts,
                        child: const Text('get_accounts'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 30)),
                        onPressed: _getSignForLogin,
                        child: const Text('get_sign_for_login'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 30)),
                        onPressed: _loginWithExternalToken,
                        child: const Text('login_wtih_external_token'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 30)),
                        onPressed: _logout,
                        child: const Text('logout'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 30)),
                        onPressed: _finalize,
                        child: const Text('finalize'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 3,
              child: Center(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Wepin Test Result',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _wepinResult,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initialize(BuildContext context) async {
    if (kDebugMode) {
      print('_initialize');
    }
    if (_wepin.isInitialized()) {
      setState(() {
        _wepinResult = 'initialize : \nAlready initialized';
      });
      return;
    }
    try {
      WidgetAttributes widgetAttributes = WidgetAttributes('ko', 'krw');
      WepinOptions wepinOptions =
          WepinOptions(_appId, _appSdkKey, widgetAttributes);
      await _wepin.initialize(context, wepinOptions);
      setState(() {
        _wepinResult = 'initialize : \nSuccessed';
      });
    } catch (e) {
      setState(() {
        _wepinResult = 'initialize : \n$e';
      });
    }
  }

  void _isInitialized() {
    if (kDebugMode) {
      print('_isInitialized');
    }
    bool result = _wepin.isInitialized();
    setState(() {
      _wepinResult = 'isInitialized : $result';
    });
  }

  Future<void> _getStatus() async {
    if (kDebugMode) {
      print('_getStatus');
    }
    try {
      String result = await _wepin.getStatus();
      setState(() {
        _wepinResult = 'getStatus : \n$result';
      });
    } catch (e) {
      setState(() {
        _wepinResult = 'getStatus : \n$e';
      });
    }
  }

  Future<void> _login() async {
    if (kDebugMode) {
      print('_login');
    }
    if (!_wepin.isInitialized()) {
      setState(() {
        _wepinResult = 'login : \nWepin is not initialized';
      });
      return;
    }
    try {
      WepinUser wepinUser = await _wepin.login();
      setState(() {
        _wepinResult = 'login : \n${wepinUser.toJson()}';
      });
    } catch (e) {
      _wepinResult = 'login : \n$e';
    }
  }

  void _openWidget() {
    if (kDebugMode) {
      print('_openWidget');
    }
    if (!_wepin.isInitialized()) {
      setState(() {
        _wepinResult = 'openWidget : \nWepin is not initialized';
      });
      return;
    }
    try {
      _wepin.openWidget();
      setState(() {
        _wepinResult = 'openWidget : \nSuccessed';
      });
    } catch (e) {
      setState(() {
        _wepinResult = 'openWidget : \n$e';
      });
    }
  }

  void _closeWidget() {
    if (kDebugMode) {
      print('_closeWidget');
    }
    if (!_wepin.isInitialized()) {
      setState(() {
        _wepinResult = 'closeWidget : \nWepin is not initialized';
      });
      return;
    }
    try {
      _wepin.closeWidget();
      setState(() {
        _wepinResult = 'closeWidget : \nSuccessed';
      });
    } catch (e) {
      setState(() {
        _wepinResult = 'closeWidget : \n$e';
      });
    }
  }

  void _getAccounts() {
    List<Account>? accounts;
    if (kDebugMode) {
      print('_getAccounts');
    }
    if (!_wepin.isInitialized()) {
      setState(() {
        _wepinResult = 'getAccounts : \nWepin is not initialized';
      });
      return;
    }
    try {
      accounts = _wepin.getAccounts();
      if (accounts != null) {
        for (var account in accounts) {
          if (kDebugMode) {
            print('network : ${account.network}');
            print('address : ${account.address}');
          }
        }
      }
      setState(() {
        _wepinResult = 'getAccounts : \n${accounts.toString()}';
      });
    } catch (e) {
      setState(() {
        _wepinResult = 'getAccounts : \n$e}';
      });
    }
  }

  void _getSignForLogin() {
    if (kDebugMode) {
      print('_getSignForLogin');
    }
    if (!_wepin.isInitialized()) {
      setState(() {
        _wepinResult = 'getSignForLogin : \nWepin is not initialized';
      });
      return;
    }
    _testSignedIdToken = _wepin.getSignForLogin(_testPrivKey, _testIdToken);
    setState(() {
      _wepinResult = 'getSignTokenForLogin : \n$_testSignedIdToken';
    });
  }

  void _loginWithExternalToken() async {
    if (kDebugMode) {
      print('_loginWithExternalToken');
    }
    try {
      WepinUser wepinUser =
          await _wepin.loginWithExternalToken(_testIdToken, _testSignedIdToken);
      setState(() {
        _wepinResult = 'loginWithExternalToken : \n${wepinUser.toJson()}';
      });
    } catch (e) {
      setState(() {
        _wepinResult = 'loginWithExternalToken : \n$e)}';
      });
    }
  }

  Future<void> _logout() async {
    if (kDebugMode) {
      print('_logout');
    }
    if (!_wepin.isInitialized()) {
      setState(() {
        _wepinResult = 'logout : \nWepin is not initialized';
      });
      return;
    }
    try {
      await _wepin.logout();
      setState(() {
        _wepinResult = 'logout : \nSuccessed';
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      setState(() {
        _wepinResult = 'logout : \n$e';
      });
    }
  }

  void _finalize() {
    if (kDebugMode) {
      print('_finalize');
    }
    _wepin.finalize();
    setState(() {
      _wepinResult = 'finalize : \nSuccessed';
    });
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
