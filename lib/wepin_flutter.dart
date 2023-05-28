library wepin_flutter;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

class WepinFlutter extends StatefulWidget {
  WepinOptions _wepinOptions;
  Uri? _linkUrl;
  String? _token;
  dynamic _appWidget;
  late int _flutterPlatformNum;
  State? _childWidget;

  WepinFlutter(this._wepinOptions, this._linkUrl, this._appWidget, {Key? key})
      : super(key: key);

  @override
  State createState() => _WepinFlutter();

  void finalize() {
    print('finalize');

    if (_childWidget == null) {
      print('_chidWidget is null');
      return;
    }

    if (!_childWidget!.mounted) {
      print('_chidWidget is not mounted');
      return;
    }

    while (Navigator.canPop(_childWidget!.context)) {
      Navigator.pop(_childWidget!.context);
    }
    _childWidget = null;
  }
}

class _WepinFlutter extends State<WepinFlutter>
    with AutomaticKeepAliveClientMixin {
  late String _loadUrl;
  String? widgetUrl = null;
  String? widgetLoginUrl = null;
  bool _webViewLoaded = false;
  late InAppWebViewController _webViewController;
  late InAppWebViewGroupOptions _inAppWebViewGroupOptions;
  String _packageName = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    print('initState'); // Noti : call 되면 최초 한번만 실행됨
    super.initState();
    if (Platform.isAndroid) {
      AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
    print(
        'appId : ${widget._wepinOptions.appId} | appKey : ${widget._wepinOptions.appKey}');
    print(
        'lang : ${widget._wepinOptions.widgetAttributes.defaultLanguage} | currency : ${widget._wepinOptions.widgetAttributes.defaultCurrency}');
    print('_linkUrl : ' + widget._linkUrl.toString());

    getPackageName();
    setWidgetServerUrlFromAppKey();
    getPlatformNumber();

    if (widget._linkUrl != null) {
      Map<String, String> param = widget._linkUrl!.queryParameters;
      widget._token = param['token'].toString();
      if (widget._token == null || widget._token!.isEmpty) {
        print('token_is_null or empty');
      }
      print('received_token : ' + widget._token!);
      widgetLoginUrl = widgetUrl! + 'login?token=' + widget._token!;
      print('widgetLoginUrl : ' + widgetLoginUrl!);
      _loadUrl = widgetLoginUrl!;
    } else {
      _loadUrl = widgetUrl!;
    }

    _inAppWebViewGroupOptions = InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
            javaScriptCanOpenWindowsAutomatically: true,
            transparentBackground: true,
            javaScriptEnabled: true,
            useOnDownloadStart: true,
            useOnLoadResource: true,
            cacheEnabled: true,
            preferredContentMode: UserPreferredContentMode.MOBILE,
            useShouldInterceptAjaxRequest: true,
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: true,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
        ),
        ios: IOSInAppWebViewOptions(
          allowsAirPlayForMediaPlayback: true,
          suppressesIncrementalRendering: true,
          ignoresViewportScaleLimits: true,
          selectionGranularity: IOSWKSelectionGranularity.DYNAMIC,
          isPagingEnabled: true,
          enableViewportScale: true,
          sharedCookiesEnabled: true,
          automaticallyAdjustsScrollIndicatorInsets: true,
          useOnNavigationResponse: true,
          allowsInlineMediaPlayback: true,
        ));
    widget._childWidget = this;
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
            top: true,
            bottom: true,
            child: Offstage(
              offstage: false,
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: Uri.parse(_loadUrl),
                ),
                initialOptions: _inAppWebViewGroupOptions,
                onWebViewCreated: (controller) {
                  print('onWebViewCreated');
                  _webViewController = controller;
                  initWebviewInterface();
                },
                onLoadStart: (controller, url) {
                  print('onLoadStart url : ' + url.toString());
                },

                onCreateWindow: (controller, action) async {
                  print('onCreateWindow');
                  return;
                },

                onLoadStop: (controller, url) {},
                onConsoleMessage: (controller, conslomessage) {
                  print('consoleMessage : ${conslomessage}');
                },

                // Noti : window.open / close 이벤트 받는 부분
                shouldOverrideUrlLoading:
                    (controller, shouldOverrideUrlLoadingRequest) async {
                  var url = shouldOverrideUrlLoadingRequest.request.url;
                  var uri = Uri.parse(url.toString());
                  print('shouldOverrideUrlLoading : ' + uri.toString());
                  if (uri.toString().startsWith('${widgetUrl!}provide/') &&
                      uri.toString().contains('domain=$_packageName')) {
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
              ),
            )));
  }

  @override
  void deactivate() {
    print('deactivate');
  }

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  String calledByWebview(List arguments) {
    print('calledByWebview data : ${arguments}');
    String response = '';
    var jsRequest = jsonEncode(arguments.first);
    print('JSRequest : $jsRequest');
    Map<String, dynamic> jsonData = jsonDecode(jsRequest);
    JSRequest request = JSRequest.fromJson(jsonData);
    if (request.header.request_to != 'flutter') {
      print('Invalid Request to : ${request.header.request_to}');
      return response;
    }
    String command = request.body.command;
    print('command : $command');
    String parameter = request.body.parameter.toString();
    print('parameter : $parameter');

    ResponseHeader responseHeader = ResponseHeader(
        id: request.header.id,
        reponse_from: request.header.request_to,
        response_to: request.header.request_from);
    ResponseBody responseBody = ResponseBody(
        command: request.body.command,
        state: 'SUCCESS',
        data: null); //Noti : General Success Response body
    print('responseHeader : ' + responseHeader.toJson().toString());
    switch (command) {
      case 'ready_to_widget':
        print('ready_to_widget');
        ResponseReadyToWidget readyToWidgetData = ResponseReadyToWidget(
            widget._wepinOptions.appKey,
            widget._wepinOptions.widgetAttributes,
            _packageName,
            widget._flutterPlatformNum,
            '1');
        responseBody.data = readyToWidgetData.toJson();
        response = jsonEncode(
            JSResponse(header: responseHeader, body: responseBody).toJson());
        break;
      case 'initialized_widget':
        print('initialized_widget');
        if (request.body.parameter['result'] == true) {
          print('init_successed');
          WepinManagerModel().setInitialized(true);
        } else {
          print('init_failed');
          WepinManagerModel().setInitialized(false);
        }
        response = jsonEncode(
            JSResponse(header: responseHeader, body: responseBody).toJson());
        break;
      case 'set_accounts':
        print('set_accounts');
        print('parameter : ${request.body.parameter!}');
        List<dynamic> receivedAccounts = request.body.parameter['accounts'];
        print('Received Accounts : $receivedAccounts');
        var jsonData = jsonEncode(receivedAccounts);
        Iterable l = json.decode(jsonData);
        List<Account> accounts =
            List<Account>.from(l.map((model) => Account.fromJson(model)));
        accounts.forEach((account) {
          print('network : ${account.network}');
          print('address : ${account.address}');
        });
        WepinManagerModel().setAccounts(accounts);
        widget._appWidget.onAccountSet();
        response = jsonEncode(
            JSResponse(header: responseHeader, body: responseBody).toJson());
        break;
      case 'close_wepin_widget':
        print('close_wepin_widget');
        response = jsonEncode(
            JSResponse(header: responseHeader, body: responseBody).toJson());
        if (mounted) {
          if (Navigator.canPop(context)) {
            print('return_to_app');
            Navigator.pop(context);
          }
        } else {
          print('wepin flutter is not mounted');
          widget._appWidget.onWepinError('wepin flutter is not mounted');
        }

      default:
        print('Invalid Command : $command');
        widget._appWidget.onWepinError('Invalid Command : $command');
        break;
    }
    return response;
  }

  void reloadWebview() {
    _webViewController.reload();
  }

  void getPlatformNumber() {
    print('getPlatformNumber');

    if (Platform.isAndroid) {
      print('Platform is Android');
      widget._flutterPlatformNum = Constants.androidPlatformNum;
    } else if (Platform.isIOS) {
      print('Platform is iOS');
      widget._flutterPlatformNum = Constants.iosPlatformNum;
    } else {
      print('UnSupported Platform');
      widget._appWidget.onWepinError('UnSupported Platform');
    }
  }

  void initWebviewInterface() {
    print('initWebviewInterface');
    String response;
    _webViewController.addJavaScriptHandler(
        handlerName: 'flutterHandler',
        callback: (args) {
          response = calledByWebview(args);
          print('JSResponse : $response');
          return response; // 웹뷰로 response 반환
        });
    return;
  }

  void setWidgetServerUrlFromAppKey() {
    print('setWidgetServerUrlFromAppKey');
    if (widget._wepinOptions.appKey.startsWith(Constants.prefixDevAppKey)) {
      widgetUrl = Constants.devWidgetUrl;
    } else if (widget._wepinOptions.appKey
        .startsWith(Constants.prefixStageAppKey)) {
      widgetUrl = Constants.stageWidgetUrl;
    } else if (widget._wepinOptions.appKey
        .startsWith(Constants.prefixLiveAppKey)) {
      widgetUrl = Constants.liveWidgetUrl;
    } else {
      print('Invalid App Key');
      widget._appWidget.onWepinError('Invalid App Key');
      return;
    }
    if (!widgetUrl!.endsWith('/')) {
      widgetUrl = '$widgetUrl!/';
    }
  }

  Future<void> getPackageName() async {
    print('getPackageName');
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _packageName = packageInfo.packageName;
    if (_packageName.isEmpty) {
      widget._appWidget.onWepinError('packageName is empty');
    }
    print('packageName : $_packageName');
  }

  void finalize() {
    print('finalize');
    widgetUrl = null;
    widgetLoginUrl = null;
  }
}
