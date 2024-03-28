import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wepin_flutter/model/sdk_facade_request.dart';
import 'package:wepin_flutter/model/wepin_manager_model.dart';
import 'package:wepin_flutter/wepin_flutter.dart';
import 'package:wepin_flutter/wepin_inputs.dart';
import 'package:wepin_flutter/wepin_outputs.dart';
import 'package:wepin_flutter/webview/ne_request.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:secp256k1/secp256k1.dart';
import 'package:convert/convert.dart';
import 'package:wepin_flutter/wepin_utils.dart';

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

  // 웹뷰의 비동기 작업이 완료되었음을 listen하기 위함

  Future<void> initialize(
      BuildContext appContext, WepinOptions wepinOptions) async {
    if (kDebugMode) {
      print('wepin_initialize');
    }
    WepinManagerModel().setInitialized(false);
    WepinManagerModel().setWepinStatus('initializing');
    _appContext = appContext;
    _wepinOptions = wepinOptions;
    //_listener = StreamController();
    await WepinManagerModel().setAppUniqueId();
    try {
      String requestPath =
          '/init?paltform=${WepinManagerModel().getPlatformNumber()}';
      Response reponse = await SdkFacadeReqeust().requestProcessor(
          _wepinOptions.appKey, requestPath, 'GET', null, null);
      //
      if (reponse.statusCode == 200) {
        Map<dynamic, dynamic> parsedData = jsonDecode(reponse.body);
        dynamic token = parsedData['token'];
        if (token != null) {
          // if (kDebugMode) {
          //   print('wepin token : $token');
          // }
          WepinManagerModel().setInitialized(true);
          WepinManagerModel().setWepinStatus('initialized');
          return;
        }
      } else {
        throw Exception(reponse.body);
      }
    } catch (e) {
      WepinManagerModel().setWepinStatus('not_initialized');
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<WepinUser> login() async {
    if (kDebugMode) {
      print('login');
    }
    if (!WepinManagerModel().getInitialized()) {
      if (kDebugMode) {
        print('wepin is not initialized');
      }
      return throw Exception('wepin is not initialized');
    }
    if (WepinManagerModel().getWepinStatus() != 'login') {
      WepinManagerModel().setWepinStatus('before_login');
      WepinManagerModel().createEventListener();
      //openWidget();
      showDialog(
          context: _appContext,
          builder: (context) {
            _wepinFlutter =
                WepinFlutter(_wepinOptions, null, _appContext.widget);
            return _wepinFlutter!;
          });

      EventResult eventResult = await WepinManagerModel().listenResultEvent();
      if (kDebugMode) {
        print('eventResult message : ${eventResult.message}');
      }
      WepinManagerModel().closeEventListener();
    }

    return WepinManagerModel().getWepinUserInfo();
  }

  void handleWepinLink(Uri linkUrl) {
    String? idToken;
    if (kDebugMode) {
      print('handleWepinLink : $linkUrl');
    }

    String deepLinkScheme = 'wepin.${_wepinOptions.appId}://';
    if (!linkUrl.toString().startsWith(deepLinkScheme)) {
      if (kDebugMode) {
        print('Invalid DeepLink Scheme');
      }
      return;
    }

    if (Platform.isIOS) {
      // if (await supportsCloseForLaunchMode(LaunchMode.inAppBrowserView)) {
      //   closeInAppWebView();
      // }
      closeInAppWebView();
    }

    Map<String, String> param = linkUrl.queryParameters;
    idToken = param['token'];
    if (idToken == null || idToken.isEmpty) {
      // wepinWallet에서 widget으로 돌아오는 경우
      if (kDebugMode) {
        //print('token_is_null or empty');
      }
      return;
    }
    if (kDebugMode) {
      //print('received_token : $idToken');
    }

    // showDialog(
    //     context: _appContext,
    //     builder: (context) {
    //       _wepinFlutter = WepinFlutter(_wepinOptions,
    //           Uri.parse('?token=${idToken}'), _appContext.widget);
    //       return _wepinFlutter!;
    //     });

    NERequestHeader neRequestHeader = NERequestHeader();
    NERequestBody neRequestBody = NERequestBody(
        command: 'set_token', parameter: SetTokenParameter(idToken));

    _wepinFlutter!.sendNativeEvent(
        NERequest(header: neRequestHeader, body: neRequestBody));
  }

  bool isInitialized() {
    return WepinManagerModel().getInitialized();
  }

  Future<String> getStatus() async {
    if (kDebugMode) {
      print('getStatus');
    }
    try {
      if (WepinManagerModel().getWepinStatus() == 'login') {
        String? refreshToken =
            await WepinManagerModel().getWepiinRefreshToken();
        // if (kDebugMode) {
        //   print('getWepiinRefreshToken : $refreshToken');
        // }
        if (refreshToken == null) {
          WepinManagerModel().setWepinStatus('initialized');
          throw Exception('Wepin refresh token is null');
        }
        if (refreshToken.isNotEmpty) {
          Response reponse = await SdkFacadeReqeust().requestProcessor(
              _wepinOptions.appKey,
              '/access_token',
              'GET',
              'refresh_token',
              refreshToken);
          if (reponse.statusCode == 401) {
            WepinManagerModel().setWepinStatus('initialized');
          }
        }
      }

      return WepinManagerModel().getWepinStatus();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  void openWidget() {
    if (kDebugMode) {
      print('wepin_openWidget');
    }
    if (!WepinManagerModel().getInitialized()) {
      if (kDebugMode) {
        print('wepin is not initialized');
      }
      throw Exception('wepin is not initialized');
    }
    if (WepinManagerModel().getWepinStatus() != 'login') {
      throw Exception('user is not logged in');
    }
    if (_wepinFlutter == null) {
      throw Exception('internal error');
    }
    try {
      showDialog(
          context: _appContext,
          builder: (context) {
            _wepinFlutter =
                WepinFlutter(_wepinOptions, null, _appContext.widget);
            return _wepinFlutter!;
          });
      // showDialog(
      //     context: _appContext,
      //     builder: (context) {
      //       return _wepinFlutter!;
      //     });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  void closeWidget() {
    if (kDebugMode) {
      print('wepin_closeWidget');
    }
    if (!WepinManagerModel().getInitialized()) {
      if (kDebugMode) {
        print('wepin is not initialized');
      }
      throw Exception('wepin is not initialized');
    }

    if (Navigator.canPop(_appContext)) {
      if (kDebugMode) {
        //print('return_to_app');
      }
      Navigator.pop(_appContext);
    }
  }

  List<Account>? getAccounts() {
    if (kDebugMode) {
      print('wepin_getAccounts');
    }

    if (!WepinManagerModel().getInitialized()) {
      if (kDebugMode) {
        print('wepin is not initialized');
      }
      throw Exception('wepin is not initialized');
    }

    return WepinManagerModel().getAccounts();
  }

  Future<WepinUser> loginWithExternalToken(String idToken, String sign) async {
    if (kDebugMode) {
      print('loginWithExternalToken');
      print('idToken : $idToken');
      print('signedValue : $sign');
    }
    if (!WepinManagerModel().getInitialized()) {
      if (kDebugMode) {
        print('wepin is not initialized');
      }
      throw Exception('wepin is not initialized');
    }
    if (idToken.isEmpty || sign.isEmpty) {
      if (kDebugMode) {
        print('Invalid Parameter');
      }
      throw Exception('Invalid Parameter');
    }

    if (WepinManagerModel().getWepinStatus() == 'login') {
      if (kDebugMode) {
        print('user is already logged in');
      }
      throw Exception('user is already logged in');
    }

    WepinManagerModel().setWepinStatus('before_login');
    WepinManagerModel().setSignedToken(sign);
    WepinManagerModel().setExternalIdToken(idToken);
    int id = WepinUtils().getTimeNowToInt();
    WepinManagerModel().createEventListener();
    showDialog(
        context: _appContext,
        builder: (context) {
          _wepinFlutter = WepinFlutter(
              _wepinOptions,
              Uri.parse(
                  'sdk/login?token=${idToken}&sign=${sign}&response_id=${id}'),
              _appContext.widget);
          return _wepinFlutter!;
        });
    EventResult eventResult = await WepinManagerModel().listenResultEvent();
    print('eventResultMessage : ${eventResult.message}');
    WepinManagerModel().closeEventListener();
    return WepinManagerModel().getWepinUserInfo();
  }

  Future<void> logout() async {
    if (kDebugMode) {
      print('logout');
    }
    if (!WepinManagerModel().getInitialized()) {
      if (kDebugMode) {
        print('wepin is not initialized');
      }
      throw Exception('wepin is not initialized');
    }
    if (WepinManagerModel().getWepinStatus() != 'login') {
      if (kDebugMode) {
        print('user is not logged in');
      }
      throw Exception('user is not logged in');
    }
    try {
      await SdkFacadeReqeust().requestProcessor(
          _wepinOptions.appKey, '/logout', 'POST', null, null);
      WepinManagerModel().setWepinStatus('initialized');
      WepinManagerModel().setAccounts(null);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<void> finalize() async {
    if (kDebugMode) {
      print('wepin_finalize');
    }
    WepinManagerModel().setInitialized(false);
    WepinManagerModel().setWepinStatus('not_initialized');
    WepinManagerModel().setAccounts(null);
    WepinManagerModel().setExternalIdToken('');
    WepinManagerModel().closeEventListener();
    if (_wepinFlutter != null) {
      _wepinFlutter!.finalize();
      _wepinFlutter = null;
    }
  }

  String getSignForLogin(String privKey, String idToken) {
    if (kDebugMode) {
      print('getSignForLogin');
      print('privateKey :$privKey');
      print('idToken : $idToken');
    }
    var pk = PrivateKey.fromHex(privKey);
    // Calculate the hash of the token
    var tokenBytes = utf8.encode(idToken); // Convert the token to bytes
    var tokenHashBytes =
        sha256.convert(tokenBytes).bytes; // Calculate SHA-256 hash
    var tokenHashHex = hex.encode(tokenHashBytes); // Convert hash to hex string
    if (kDebugMode) {
      print('hashedIdToken : $tokenHashHex');
    }
    var sig = pk.signature(tokenHashHex);
    return sig.toString();
  }

  // Future<String> listenFinishEvent() async {
  //   String event = await _listener.stream.first;
  //   return event;
  // }
}
