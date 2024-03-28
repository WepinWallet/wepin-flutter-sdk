library wepin_flutter;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wepin_flutter/model/constants.dart';
import 'package:wepin_flutter/model/wepin_manager_model.dart';
import 'package:wepin_flutter/webview/js_request.dart';
import 'package:wepin_flutter/webview/js_response.dart';
import 'package:wepin_flutter/webview/ne_request.dart';
import 'package:wepin_flutter/wepin_utils.dart';

import 'wepin_inputs.dart';
import 'wepin_outputs.dart';

// ignore: must_be_immutable

late InAppWebViewController _webViewController;

class WepinFlutter extends StatefulWidget {
  final WepinOptions _wepinOptions;
  final Uri? _optionUrl;
  final dynamic _appWidget;
  //final String? _optionUrl;
  late int _flutterPlatformNum;
  State? _childWidget;
  //StreamController<String> _resultListener;

  WepinFlutter(this._wepinOptions, this._optionUrl, this._appWidget, {Key? key})
      : super(key: key);

  @override
  State createState() => _WepinFlutter();

  void finalize() {
    if (kDebugMode) {
      print('finalize');
    }

    if (_childWidget == null) {
      if (kDebugMode) {
        print('_chidWidget is null');
      }
      return;
    }

    if (!_childWidget!.mounted) {
      if (kDebugMode) {
        print('_chidWidget is not mounted');
      }
      return;
    }
    while (Navigator.canPop(_childWidget!.context)) {
      Navigator.pop(_childWidget!.context);
    }
    _childWidget = null;
    //closeInAppWebView();
  }

  void sendNativeEvent(NERequest request) async {
    String requestMsg = jsonEncode(request);
    if (kDebugMode) {
      print('sendNativeEvent : $requestMsg');
    }
    await _webViewController.callAsyncJavaScript(
        functionBody: 'onFlutterEvent($requestMsg)');
  }

  void loadUrlWebivew(String url) {
    // Reload the WebView with a different URL
    if (kDebugMode) {
      print('loadUrlWebivew : $url');
    }
    _webViewController.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }
}

class _WepinFlutter extends State<WepinFlutter> {
  late String _loadUrl;
  String? widgetUrl;
  String? widgetLoginUrl;
  Map<String, dynamic>? _userInfoData;
  @override
  void initState() {
    if (kDebugMode) {
      print('wepin_flutter_initState');
    } // Noti : call 되면 최초 한번만 실행됨
    super.initState();
    if (Platform.isAndroid) {
      InAppWebViewController.setWebContentsDebuggingEnabled(true);
    }

    if (kDebugMode) {
      print(
          'appId : ${widget._wepinOptions.appId} | appKey : ${widget._wepinOptions.appKey}');
    }
    if (kDebugMode) {
      print(
          'lang : ${widget._wepinOptions.widgetAttributes.defaultLanguage} | currency : ${widget._wepinOptions.widgetAttributes.defaultCurrency}');
    }
    if (kDebugMode) {
      print('_optionUrl : ${widget._optionUrl}');
    }
    //setWidgetServerUrlFromAppKey();
    widgetUrl =
        WepinManagerModel().getWidgetUrlFromAppKey(widget._wepinOptions.appKey);
    widget._flutterPlatformNum = WepinManagerModel().getPlatformNumber();

    if (widget._optionUrl != null) {
      _loadUrl = widgetUrl! + widget._optionUrl.toString();
    } else {
      _loadUrl = widgetUrl!;
    }
    if (kDebugMode) {
      print('widget_load_url : $_loadUrl');
    }
    widget._childWidget = this;
    // _inAppWebViewGroupOptions = InAppWebViewGroupOptions(
    //     crossPlatform: InAppWebViewOptions(
    //         javaScriptCanOpenWindowsAutomatically: true,
    //         transparentBackground: true,
    //         javaScriptEnabled: true,
    //         useOnDownloadStart: true,
    //         useOnLoadResource: true,
    //         cacheEnabled: true,
    //         preferredContentMode: UserPreferredContentMode.MOBILE,
    //         useShouldInterceptAjaxRequest: true,
    //         useShouldOverrideUrlLoading: true,
    //         mediaPlaybackRequiresUserGesture: true,
    //         allowFileAccessFromFileURLs: true,
    //         allowUniversalAccessFromFileURLs: true),
    //     android: AndroidInAppWebViewOptions(
    //       useHybridComposition: true,
    //     ),
    //     ios: IOSInAppWebViewOptions(
    //       allowsAirPlayForMediaPlayback: true,
    //       suppressesIncrementalRendering: true,
    //       ignoresViewportScaleLimits: true,
    //       selectionGranularity: IOSWKSelectionGranularity.DYNAMIC,
    //       isPagingEnabled: true,
    //       enableViewportScale: true,
    //       sharedCookiesEnabled: true,
    //       automaticallyAdjustsScrollIndicatorInsets: true,
    //       useOnNavigationResponse: true,
    //       allowsInlineMediaPlayback: true,
    //     ));

    // WepinManagerModel().setInitialized(true);
    // WepinManagerModel().setWepinStatus('initialized');
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('wepin_flutter_build');
    }
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
            top: true,
            bottom: true,
            child: Visibility(
              visible: true,
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_loadUrl)),
                //initialUrlRequest: URLRequest(url: WebUri('about:blank')),
                //initialOptions: _inAppWebViewGroupOptions,
                initialSettings: InAppWebViewSettings(
                  transparentBackground: true,
                  safeBrowsingEnabled: true,
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                  //supportMultipleWindows: true,
                ),
                onWebViewCreated: (controller) {
                  if (kDebugMode) {
                    print('onWebViewCreated');
                  }
                  _webViewController = controller;
                  initWebviewInterface();
                },
                onLoadStart: (controller, url) {
                  if (kDebugMode) {
                    //print('onLoadStart url : $url');
                  }
                },
                onCreateWindow: (controller, action) async {
                  if (kDebugMode) {
                    //print('onCreateWindow openUrl : ${action.request.url}');
                  }
                  //Navigator.pop(context);
                  // Noti : iOS 인 경우 window.open 이벤트는 요기서 처리
                  if (Platform.isIOS) {
                    if (action.request.url != null) {
                      Uri openUrl = Uri.parse(action.request.url.toString());
                      if (await canLaunchUrl(openUrl)) {
                        launchUrl(openUrl, mode: LaunchMode.inAppBrowserView);
                        _webViewController
                            .reload(); // 인앱브라우저가 닫혔을 경우처리..이벤트를 못받으므로..
                      }
                      return true;
                    }
                  }
                },
                onExitFullscreen: (controller) {
                  if (kDebugMode) {
                    print('onExitFullscreen');
                  }
                },
                onCloseWindow: (controller) {
                  if (kDebugMode) {
                    print('onCloseWindow');
                  }
                },

                onLoadStop: (controller, url) {
                  if (kDebugMode) {
                    //print('onLoadStop : $url');
                  }
                  //Navigator.of(context).pop();
                },
                onConsoleMessage: (controller, conslomessage) {
                  if (kDebugMode) {
                    print('consoleMessage : $conslomessage');
                  }
                },

                shouldOverrideUrlLoading:
                    (controller, shouldOverrideUrlLoadingRequest) async {
                  var url = shouldOverrideUrlLoadingRequest.request.url;
                  var uri = Uri.parse(url.toString());
                  if (kDebugMode) {
                    //print('shouldOverrideUrlLoading : $uri');
                  }
                  // Noti : Android 인 경우 window.open 이벤트는 요기서 처리
                  if (Platform.isAndroid) {
                    if (uri.toString().isNotEmpty) {
                      if (await canLaunchUrl(uri)) {
                        launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                        _webViewController
                            .reload(); // 인앱브라우저가 닫혔을 경우처리..이벤트를 못받으므로..
                        //_webViewController.goForward();
                      }
                      return NavigationActionPolicy.CANCEL;
                    }
                  }
                  return NavigationActionPolicy.ALLOW;
                },
              ),
            )));
  }

  @override
  void deactivate() {
    super.deactivate();
    if (kDebugMode) {
      print('wepin_flutter_deactivate');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('wepin_flutter_dispose');
    }
    super.dispose();
  }

  Future<String> calledByWebview(List arguments) async {
    if (kDebugMode) {
      //print('calledByWebview data : $arguments');
    }
    var jsRequest;
    JSRequest? request;
    String command = '';
    String response = '';
    JSResponse? jsResponse;
    ResponseHeader? responseHeader;
    ResponseBody? responseBody;
    if (arguments.first is! String) {
      jsRequest = jsonEncode(arguments.first);
    } else {
      jsRequest = arguments.first;
    }

    if (kDebugMode) {
      print('JSRequest : $jsRequest');
    }
    Map<String, dynamic> jsonData = jsonDecode(jsRequest);

    if (jsonData['header'] != null &&
        jsonData['header']['request_to'] != null) {
      request = JSRequest.fromJson(jsonData);

      if (request.header.request_to != 'flutter') {
        if (kDebugMode) {
          print('Invalid Request to : ${request.header.request_to}');
        }

        return response;
      }

      command = request.body.command;
      if (kDebugMode) {
        //print('command : $command');
      }

      responseHeader = ResponseHeader(
          id: request.header.id,
          reponse_from: request.header.request_to,
          response_to: request.header.request_from);
      responseBody = ResponseBody(
          command: request.body.command,
          state: 'SUCCESS',
          data: null); //Noti : General Success Response body
      if (kDebugMode) {
        print('responseHeader : ${responseHeader.toJson()}');
      }
    } else {
      // if (jsonData['header']['response_to'] != 'flutter') {
      //   print('Invalid Response to : ${jsonData['header']['response_to']}');
      //   return '';
      // }
      // command = jsonData['body']['command'];

      jsResponse = JSResponse.fromJson(jsonData);

      if (jsResponse.header.response_to != 'flutter') {
        if (kDebugMode) {
          print('Invalid Response to : ${jsResponse.header.response_to}');
        }
        return '';
      }
      command = jsResponse.body.command;
    }

    switch (command) {
      case 'ready_to_widget':
        if (kDebugMode) {
          print('ready_to_widget');
        }
        String domain = WepinManagerModel().getAppUniqueId();
        ResponseReadyToWidget readyToWidgetData = ResponseReadyToWidget(
            widget._wepinOptions.appKey,
            widget._wepinOptions.widgetAttributes,
            domain,
            widget._flutterPlatformNum,
            Constants.sdkVersion,
            widget._wepinOptions.appId);
        responseBody!.data = readyToWidgetData.toJson();
        response = jsonEncode(
            JSResponse(header: responseHeader!, body: responseBody).toJson());
        //sendFinishEvent('testevent');
        //WepinManagerModel().sendResultEvent('testevent');
        //WepinManagerModel().sendResultEvent(false, 'testeventMessage');
        break;
      case 'initialized_widget':
        if (kDebugMode) {
          print('initialized_widget');
        }

        if (request!.body.parameter['result'] == true) {
          if (kDebugMode) {
            print('init_successed');
          }
          //WepinManagerModel().setInitialized(true);
        } else {
          if (kDebugMode) {
            print('init_failed');
          }
          //WepinManagerModel().setInitialized(false);
        }
        response = jsonEncode(
            JSResponse(header: responseHeader!, body: responseBody!).toJson());

        break;
      case 'set_accounts':
        if (kDebugMode) {
          print('set_accounts');
          //print('parameter : ${request!.body.parameter!}');
        }
        List<dynamic> receivedAccounts = request!.body.parameter['accounts'];
        if (kDebugMode) {
          //print('Received Accounts : $receivedAccounts');
        }
        var jsonData = jsonEncode(receivedAccounts);
        Iterable l = json.decode(jsonData);
        List<Account> accounts =
            List<Account>.from(l.map((model) => Account.fromJson(model)));
        for (var account in accounts) {
          if (kDebugMode) {
            print('network : ${account.network}');
            print('address : ${account.address}');
          }
        }
        WepinManagerModel().setAccounts(accounts);
        if (accounts.isEmpty) {
          if (WepinManagerModel().getWepinStatus() == 'login') {
            // 위젯 웹뷰에서 로그아웃 눌렸을때 처리
            WepinManagerModel().setWepinStatus('initialized');
          }
        }
        response = jsonEncode(
            JSResponse(header: responseHeader!, body: responseBody!).toJson());
        break;
      case 'close_wepin_widget':
        if (kDebugMode) {
          print('close_wepin_widget');
        }
        if (Platform.isAndroid) {
          if (WepinManagerModel().getWepinStatus() == 'login_before_register') {
            response = jsonEncode(
                JSResponse(header: responseHeader!, body: responseBody!)
                    .toJson());
            break;
          }
        }
        response = jsonEncode(
            JSResponse(header: responseHeader!, body: responseBody!).toJson());
        WepinManagerModel().closeEventListener();
        Future.delayed(Duration(microseconds: 500), () {
          if (mounted) {
            if (Navigator.canPop(context)) {
              if (kDebugMode) {
                //print('return_to_app');
              }
              Navigator.pop(context);
            }
          }
        });
        break;
      case 'login_with_external_token':
        // external idToken Login에 대한 웹뷰 응답처리
        if (kDebugMode) {
          print('login_with_external_token');
        }
        if (jsResponse!.body.state == 'SUCCESS') {
          String loginStatus = jsResponse.body.data['loginStatus'];
          if (kDebugMode) {
            print('wepinLoginStatus : $loginStatus');
            //print('wepinLoginToken : $loginToken');
          }
          if (loginStatus == 'complete') {
            //_userInfoData = jsResponse.body.data['userInfo'];
            WepinManagerModel().setWepinStatus('login');
            // if (kDebugMode) {
            //   print('_userInfoData : $_userInfoData');
            // }
            WepinUser wepinUser =
                WepinUser.fromJson(jsResponse.body.data['userInfo']);
            WepinManagerModel().setWepinUserInfo(wepinUser);
            WepinManagerModel()
                .sendResultEvent(true, wepinUser.toJson().toString());
          } else {
            WepinManagerModel().setWepinStatus('login_before_register');
            String signedToken = WepinManagerModel().getSignedToken();
            String externalIdToken = WepinManagerModel().getExternalIdToken();
            _regiterWithWidget(
                loginStatus,
                (jsResponse.body.data['pinRequired']).toString(),
                externalIdToken,
                signedToken);
          }
        }
        break;
      case 'set_local_storage':
        if (kDebugMode) {
          print('set_local_storage');
        }
        if (WepinManagerModel().getWepinStatus() == 'before_login' ||
            WepinManagerModel().getWepinStatus() == 'login_before_register') {
          WepinUser wepinUser = WepinUser.fromJson(
              request!.body.parameter['data']['user_login_info']);
          WepinManagerModel().setWepinUserInfo(wepinUser);
          if (request.body.parameter['data']['user_login_info']['status'] ==
              'success') {
            // save wepin refresh & access token
            String jsonStr =
                jsonEncode(request.body.parameter['data']['wepin:connectUser']);
            WepinManagerModel()
                .setSecureStorageData(Constants.wepinTokenKeyName, jsonStr);
            WepinManagerModel().setWepinStatus('login');
            WepinManagerModel()
                .sendResultEvent(true, wepinUser.toJson().toString());
          }
        }

        // 결과 출력
        response = jsonEncode(
            JSResponse(header: responseHeader!, body: responseBody!).toJson());
        break;
      case 'set_user_info':
        if (kDebugMode) {
          print('set_user_info');
        }
        // if (WepinManagerModel().getWepinStatus() == 'before_login' ||
        //     WepinManagerModel().getWepinStatus() == 'login_before_register') {
        //   if (request!.body.parameter['status'] == 'success') {
        //     WepinManagerModel().setWepinStatus('login');
        //   } else {
        //     WepinManagerModel().setWepinStatus('initialized');
        //   }
        //   WepinUser wepinUser = WepinUser.fromJson(request.body.parameter);
        //   WepinManagerModel().setWepinUserInfo(wepinUser);
        //   WepinManagerModel()
        //       .sendResultEvent(true, wepinUser.toJson().toString());
        // }

        response = jsonEncode(
            JSResponse(header: responseHeader!, body: responseBody!).toJson());
        break;
      default:
        if (kDebugMode) {
          print('Invalid Command : $command');
        }
//        widget._appWidget.onWepinError('Invalid Command : $command');
        throw Exception('Invalid Command : $command');
      //break;
    }
    return response;
  }

  void reloadWebview() {
    _webViewController.reload();
  }

  _regiterWithWidget(String loginStatus, String pinRequired, String token,
      String singedToken) {
    if (kDebugMode) {
      print('_regiterWithWidget');
    }
    int id = WepinUtils().getTimeNowToInt();
    String url =
        '${widgetUrl!}sdk/register?loginStatus=$loginStatus&pinRequired=$pinRequired&token=$token&sign=$singedToken&response_id=$id';
    _webViewController.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }

  void initWebviewInterface() {
    if (kDebugMode) {
      print('initWebviewInterface');
    }
    //String response;
    String response;
    _webViewController.addJavaScriptHandler(
        handlerName: 'flutterHandler',
        callback: (args) async {
          response = await calledByWebview(args);
          if (kDebugMode) {
            print('JSResponse : $response');
          }
          if (response.isNotEmpty) {
            return response; // 웹뷰로 response 반환
          }
        });
    return;
  }

  // void setWidgetServerUrlFromAppKey() {
  //   if (kDebugMode) {
  //     print('setWidgetServerUrlFromAppKey');
  //   }

  //   if (widget._wepinOptions.appKey.startsWith(Constants.prefixDevAppKey)) {
  //     widgetUrl = Constants.devWidgetUrl;
  //   } else if (widget._wepinOptions.appKey
  //       .startsWith(Constants.prefixStageAppKey)) {
  //     widgetUrl = Constants.stageWidgetUrl;
  //   } else if (widget._wepinOptions.appKey
  //       .startsWith(Constants.prefixLiveAppKey)) {
  //     widgetUrl = Constants.prodWidgetUrl;
  //   } else {
  //     if (kDebugMode) {
  //       print('Invalid App Key');
  //     }
  //     widget._appWidget.onWepinError('Invalid App Key');
  //   }
  //   if (!widgetUrl!.endsWith('/')) {
  //     widgetUrl = '$widgetUrl/';
  //   }
  // }
}
