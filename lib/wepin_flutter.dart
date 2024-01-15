library wepin_flutter;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

import 'wepin_inputs.dart';
import 'wepin_outputs.dart';

// ignore: must_be_immutable

late InAppWebViewController _webViewController;

class WepinFlutter extends StatefulWidget {
  final WepinOptions _wepinOptions;
  final Uri? _linkUrl;
  String? _token;
  final dynamic _appWidget;
  late int _flutterPlatformNum;
  State? _childWidget;

  WepinFlutter(this._wepinOptions, this._linkUrl, this._appWidget, {Key? key})
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
    closeInAppWebView();
  }

  void sendNativeEvent(NERequest request) async {
    String requestMsg = jsonEncode(request);
    if (kDebugMode) {
      print('sendNativeEvent : $requestMsg');
    }
    await _webViewController.callAsyncJavaScript(
        functionBody: 'onFlutterEvent($requestMsg)');
  }
}

class _WepinFlutter extends State<WepinFlutter> {
  late String _loadUrl;
  String? widgetUrl;
  String? widgetLoginUrl;
  String _packageName = '';

  @override
  void initState() {
    if (kDebugMode) {
      print('initState');
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
      print('_linkUrl : ${widget._linkUrl}');
    }

    getPackageName();
    setWidgetServerUrlFromAppKey();
    getPlatformNumber();

    if (widget._linkUrl != null) {
      Map<String, String> param = widget._linkUrl!.queryParameters;
      widget._token = param['token'].toString();
      if (widget._token == null || widget._token!.isEmpty) {
        if (kDebugMode) {
          print('token_is_null or empty');
        }
      }
      if (kDebugMode) {
        print('received_token : ${widget._token!}');
      }
      widgetLoginUrl = '${widgetUrl!}login?token=${widget._token!}';
      if (kDebugMode) {
        print('widgetLoginUrl : ${widgetLoginUrl!}');
      }
      _loadUrl = widgetLoginUrl!;
    } else {
      _loadUrl = widgetUrl!;
    }

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
    widget._childWidget = this;
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('build');
    }
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
            top: true,
            bottom: true,
            child: Offstage(
              offstage: false,
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_loadUrl)),
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
                    print('onLoadStart url : $url');
                  }
                },
                onCreateWindow: (controller, action) async {
                  if (kDebugMode) {
                    print('onCreateWindow openUrl : ${action.request.url}');
                  }
                  // Noti : iOS 인 경우 window.open 이벤트는 요기서 처리
                  if (Platform.isIOS) {
                    if (action.request.url != null) {
                      Uri openUrl = Uri.parse(action.request.url.toString());
                      if (await canLaunchUrl(openUrl)) {
                        launchUrl(openUrl, mode: LaunchMode.inAppBrowserView);
                      }
                      return true;
                    }
                  }
                },

                onCloseWindow: (controller) {
                  if (kDebugMode) {
                    print('onCloseWindow');
                  }
                },

                onLoadStop: (controller, url) {
                  if (kDebugMode) {
                    print('onLoadStop : $url');
                  }
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
                    print('shouldOverrideUrlLoading : $uri');
                  }
                  // Noti : Android 인 경우 window.open 이벤트는 요기서 처리
                  if (Platform.isAndroid) {
                    if (uri.toString().isNotEmpty) {
                      if (await canLaunchUrl(uri)) {
                        launchUrl(uri, mode: LaunchMode.inAppBrowserView);
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
      print('deactivate');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('dispose');
    }
    super.dispose();
  }

  String calledByWebview(List arguments) {
    if (kDebugMode) {
      print('calledByWebview data : $arguments');
    }
    String response = '';
    var jsRequest = jsonEncode(arguments.first);
    if (kDebugMode) {
      print('JSRequest : $jsRequest');
    }
    Map<String, dynamic> jsonData = jsonDecode(jsRequest);
    JSRequest request = JSRequest.fromJson(jsonData);
    if (request.header.request_to != 'flutter') {
      if (kDebugMode) {
        print('Invalid Request to : ${request.header.request_to}');
      }
      return response;
    }
    String command = request.body.command;
    if (kDebugMode) {
      print('command : $command');
    }
    String parameter = request.body.parameter.toString();
    if (kDebugMode) {
      print('parameter : $parameter');
    }

    ResponseHeader responseHeader = ResponseHeader(
        id: request.header.id,
        reponse_from: request.header.request_to,
        response_to: request.header.request_from);
    ResponseBody responseBody = ResponseBody(
        command: request.body.command,
        state: 'SUCCESS',
        data: null); //Noti : General Success Response body
    if (kDebugMode) {
      print('responseHeader : ${responseHeader.toJson()}');
    }
    switch (command) {
      case 'ready_to_widget':
        if (kDebugMode) {
          print('ready_to_widget');
        }
        ResponseReadyToWidget readyToWidgetData = ResponseReadyToWidget(
            widget._wepinOptions.appKey,
            widget._wepinOptions.widgetAttributes,
            _packageName,
            widget._flutterPlatformNum,
            Constants.widgetInterfaceVersion);
        responseBody.data = readyToWidgetData.toJson();
        response = jsonEncode(
            JSResponse(header: responseHeader, body: responseBody).toJson());
        break;
      case 'initialized_widget':
        if (kDebugMode) {
          print('initialized_widget');
        }
        if (request.body.parameter['result'] == true) {
          if (kDebugMode) {
            print('init_successed');
          }
          WepinManagerModel().setInitialized(true);
        } else {
          if (kDebugMode) {
            print('init_failed');
          }
          WepinManagerModel().setInitialized(false);
        }
        response = jsonEncode(
            JSResponse(header: responseHeader, body: responseBody).toJson());
        break;
      case 'set_accounts':
        if (kDebugMode) {
          print('set_accounts');
          print('parameter : ${request.body.parameter!}');
        }
        List<dynamic> receivedAccounts = request.body.parameter['accounts'];
        if (kDebugMode) {
          print('Received Accounts : $receivedAccounts');
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
        widget._appWidget.onAccountSet();
        response = jsonEncode(
            JSResponse(header: responseHeader, body: responseBody).toJson());
        break;
      case 'close_wepin_widget':
        if (kDebugMode) {
          print('close_wepin_widget');
        }
        response = jsonEncode(
            JSResponse(header: responseHeader, body: responseBody).toJson());
        if (mounted) {
          if (Navigator.canPop(context)) {
            if (kDebugMode) {
              print('return_to_app');
            }
            Navigator.pop(context);
          }
        } else {
          if (kDebugMode) {
            print('wepin flutter is not mounted');
          }
          widget._appWidget.onWepinError('wepin flutter is not mounted');
        }
        break;
      default:
        if (kDebugMode) {
          print('Invalid Command : $command');
        }
        widget._appWidget.onWepinError('Invalid Command : $command');
        break;
    }
    return response;
  }

  void reloadWebview() {
    _webViewController.reload();
  }

  void getPlatformNumber() {
    if (kDebugMode) {
      print('getPlatformNumber');
    }

    if (Platform.isAndroid) {
      if (kDebugMode) {
        print('Platform is Android');
      }
      widget._flutterPlatformNum = Constants.androidPlatformNum;
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        print('Platform is iOS');
      }
      widget._flutterPlatformNum = Constants.iosPlatformNum;
    } else {
      if (kDebugMode) {
        print('UnSupported Platform');
      }
      widget._appWidget.onWepinError('UnSupported Platform');
    }
  }

  void initWebviewInterface() {
    if (kDebugMode) {
      print('initWebviewInterface');
    }
    String response;
    _webViewController.addJavaScriptHandler(
        handlerName: 'flutterHandler',
        callback: (args) {
          response = calledByWebview(args);
          if (kDebugMode) {
            print('JSResponse : $response');
          }
          if (response.isNotEmpty) {
            return response; // 웹뷰로 response 반환
          }
        });
    return;
  }

  void setWidgetServerUrlFromAppKey() {
    if (kDebugMode) {
      print('setWidgetServerUrlFromAppKey');
    }
    if (widget._wepinOptions.appKey.startsWith(Constants.prefixDevAppKey)) {
      widgetUrl = Constants.devWidgetUrl;
    } else if (widget._wepinOptions.appKey
        .startsWith(Constants.prefixStageAppKey)) {
      widgetUrl = Constants.stageWidgetUrl;
    } else if (widget._wepinOptions.appKey
        .startsWith(Constants.prefixLiveAppKey)) {
      widgetUrl = Constants.liveWidgetUrl;
    } else {
      if (kDebugMode) {
        print('Invalid App Key');
      }
      widget._appWidget.onWepinError('Invalid App Key');
    }
    if (!widgetUrl!.endsWith('/')) {
      widgetUrl = '$widgetUrl!/';
    }
  }

  Future<void> getPackageName() async {
    if (kDebugMode) {
      print('getPackageName');
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _packageName = packageInfo.packageName;
    WepinManagerModel().setAppUniqueId(_packageName);
    if (_packageName.isEmpty) {
      widget._appWidget.onWepinError('packageName is empty');
    }
    if (kDebugMode) {
      print('packageName : $_packageName');
    }
  }
}
