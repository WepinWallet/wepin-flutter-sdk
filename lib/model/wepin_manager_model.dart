import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wepin_flutter/model/constants.dart';
import '../wepin_outputs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class WepinManagerModel {
  List<Account>? _accountList;
  late bool _isInitialized;
  late String _appUniqueId;
  String _signedToken = '';
  String _externalIdToken = '';
  String _wepinLifeCycle = 'not_initialized';
  late WepinUser _wepinUser;

  static final _storage = FlutterSecureStorage();
  static final WepinManagerModel _instance = WepinManagerModel._internal();

  late StreamSubscription<String> subscription;
  StreamController<String> _controller = StreamController<String>();

  // singleton
  factory WepinManagerModel() => _instance;

  WepinManagerModel._internal() {
    _isInitialized = false;
    _accountList = null;

    //_eventListener = StreamController();
  }

  setInitialized(bool isInit) {
    _isInitialized = isInit;
  }

  bool getInitialized() {
    return _isInitialized;
  }

  setAccounts(List<Account>? accounts) {
    _accountList = accounts;
  }

  List<Account>? getAccounts() {
    return _accountList;
  }

  String getAppUniqueId() {
    return _appUniqueId;
  }

  void setSignedToken(String singedValue) {
    _signedToken = singedValue;
  }

  String getSignedToken() {
    return _signedToken;
  }

  void setExternalIdToken(String token) {
    _externalIdToken = token;
  }

  String getExternalIdToken() {
    return _externalIdToken;
  }

  Future<void> setAppUniqueId() async {
    if (kDebugMode) {
      print('setAppUniqueId');
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appUniqueId = packageInfo.packageName;
    if (kDebugMode) {
      print('appUniqueId : $_appUniqueId');
    }
  }

  // setUserInfo(UserInfo? userInfo) {
  //   _userInfo = userInfo;
  // }

  setWepinUserInfo(WepinUser wepinUser) {
    _wepinUser = wepinUser;
  }

  // UserInfo? getUserInfo() {
  //   return _userInfo;
  // }

  WepinUser getWepinUserInfo() {
    return _wepinUser;
  }

  Future<void> setSecureStorageData(String key, String value) async {
    if (kDebugMode) {
      print('Data stored key : $key');
      print('Data stored value : $value');
    }
    if (key.isEmpty || value.isEmpty) {
      return;
    }
    await _storage.write(key: key, value: value);
  }

  Future<String?> getSecureStorageData(String key) async {
    String? value = await _storage.read(key: key);
    if (kDebugMode) {
      print('getSecureStorageData : $value');
    }

    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  Future<String?> getWepiinAccessToken() async {
    String? secureData =
        await getSecureStorageData(Constants.wepinTokenKeyName);
    if (secureData == null) {
      return null;
    }
    Map<String, dynamic> data = json.decode(secureData);
    String accessToken = data['accessToken'];
    if (kDebugMode) {
      print('get_AccessToken: $accessToken');
    }

    return accessToken;
  }

  Future<String?> getWepiinRefreshToken() async {
    String? secureData =
        await getSecureStorageData(Constants.wepinTokenKeyName);
    if (secureData == null) {
      return null;
    }
    Map<String, dynamic> data = json.decode(secureData);
    String refreshToken = data['refreshToken'];
    // if (kDebugMode) {
    //   print('get_refreshToken: $refreshToken');
    // }
    return refreshToken;
  }

  void setWepinStatus(String status) {
    if (kDebugMode) {
      print('setWepinStatus : $status');
    }
    _wepinLifeCycle = status;
  }

  String getWepinStatus() {
    if (kDebugMode) {
      print('getWepinStatus');
    }
    return _wepinLifeCycle;
  }

  int getPlatformNumber() {
    if (kDebugMode) {
      print('getPlatformNumber');
    }

    if (Platform.isAndroid) {
      if (kDebugMode) {
        print('Platform is Android');
      }
      return Constants.androidPlatformNum;
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        print('Platform is iOS');
      }
      //widget._flutterPlatformNum = Constants.iosPlatformNum;
      return Constants.iosPlatformNum;
    } else {
      if (kDebugMode) {
        print('UnSupported Platform');
      }
      return -1;
    }
  }

  void finalize() {
    _accountList = null;
    _isInitialized = false;
    _appUniqueId = '';
    _controller.close();
    _wepinLifeCycle = 'not_initialized';
  }

  void createEventListener() {
    if (kDebugMode) {
      print('createEventListener');
    }

    if (!_controller.isClosed) {
      _controller.close();
    }
    _controller = StreamController<String>();
  }

  Future<EventResult> listenResultEvent() async {
    String receivedEvent = await _controller.stream.first;
    if (kDebugMode) {
      print('receivedEvent : $receivedEvent');
    }

    //_controller.close();
    EventResult eventResult = EventResult.fromJson(jsonDecode(receivedEvent));
    return eventResult;
  }

  void sendResultEvent(bool result, String? message) {
    if (kDebugMode) {
      print('sendResultEvent [result] : $result  [message] : $message');
    }
    if (_controller.isClosed) {
      return;
    }
    EventResult eventResult = EventResult(result, message);

    String jsonResult = jsonEncode(eventResult.toJson());
    _controller.sink.add(jsonResult);
  }

  void closeEventListener() {
    if (kDebugMode) {
      print('closeEventListener');
    }
    _controller.close();
  }

  String getWidgetUrlFromAppKey(String appKey) {
    String widgetUrl = '';
    if (kDebugMode) {
      print('getWidgetUrlFromAppKey');
    }

    if (appKey.startsWith(Constants.prefixDevAppKey)) {
      widgetUrl = Constants.devWidgetUrl;
    } else if (appKey.startsWith(Constants.prefixStageAppKey)) {
      widgetUrl = Constants.stageWidgetUrl;
    } else if (appKey.startsWith(Constants.prefixLiveAppKey)) {
      widgetUrl = Constants.prodWidgetUrl;
    } else {
      if (kDebugMode) {
        print('Invalid App Key');
        return widgetUrl;
      }
    }
    if (!widgetUrl!.endsWith('/')) {
      widgetUrl = '$widgetUrl/';
    }
    return widgetUrl;
  }
}

class EventResult {
  final bool _result;
  final String? _message;

  EventResult(this._result, this._message);

  Map<String, dynamic> toJson() {
    return {'result': _result, 'message': _message};
  }

  factory EventResult.fromJson(Map<String, dynamic> json) {
    return EventResult(
      json['result'] ?? false,
      json['message'], // 'message' can be null
    );
  }

  bool get result => _result;
  String? get message => _message;
}
