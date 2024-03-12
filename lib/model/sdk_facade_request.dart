import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:wepin_flutter/model/constants.dart';
import 'package:wepin_flutter/model/wepin_manager_model.dart';
import 'package:http/http.dart' as http;

class SdkFacadeReqeust {
  Future<http.Response> requestProcessor(String appKey, String requestPath,
      String method, String? queryParamKey, String? queryParamData) async {
    String sdkFacadeUrl = '';
    String originUrl = '';
    final http.Response response;

    if (appKey.isEmpty || requestPath.isEmpty) {
      if (kDebugMode) {
        print('appkey or requestPath is empty');
      }
      throw Exception('appKey or requestPath is empty');
    }

    if (appKey.startsWith(Constants.prefixDevAppKey)) {
      sdkFacadeUrl = Constants.devSdkFacadeUrl;
      originUrl = Constants.devWidgetUrl;
    } else if (appKey.startsWith(Constants.prefixStageAppKey)) {
      sdkFacadeUrl = Constants.stageSdkFacadeUrl;
      originUrl = Constants.stageWidgetUrl;
    } else if (appKey.startsWith(Constants.prefixLiveAppKey)) {
      sdkFacadeUrl = Constants.prodSdkFacadeUrl;
      originUrl = Constants.prodWidgetUrl;
    } else {
      if (kDebugMode) {
        print('Invalid App Key');
      }
      throw Exception('Invalid App Key');
    }
    Uri requestUrl;
    String urlStr = sdkFacadeUrl + requestPath;
    if (queryParamKey != null && queryParamData != null) {
      var queryParam = {queryParamKey: queryParamData};
      requestUrl = Uri.parse(urlStr).replace(queryParameters: queryParam);
    } else {
      requestUrl = Uri.parse(urlStr);
    }

    if (requestPath.split('?')[0] == '/init' && method.toUpperCase() == 'GET') {
      Map<String, String> initHeader = {
        'origin': originUrl,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-API-KEY': appKey,
        'X-API-DOMAIN': WepinManagerModel().getAppUniqueId(),
      };
      response = await http.get(requestUrl, headers: initHeader);
    } else if (requestPath.split('?')[0] == '/access-token' &&
        method.toUpperCase() == 'GET') {
      Map<String, String> accessTokenHeader = {
        'origin': originUrl,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        //'X-API-DOMAIN': WepinManagerModel().getAppUniqueId(),
        'X-API-KEY': appKey,
      };
      response = await http.get(requestUrl, headers: accessTokenHeader);
    } else {
      Map<String, String> commonHeader = {
        'origin': originUrl,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-API-KEY': appKey,
        'Authorization':
            'Bearer ${await WepinManagerModel().getWepiinAccessToken()}',
      };
      if (method.toUpperCase() == 'GET') {
        response = await http.get(requestUrl, headers: commonHeader);
      } else if (method.toUpperCase() == 'POST') {
        response = await http.post(requestUrl, headers: commonHeader);
      } else {
        throw Exception('Not Supported Method');
      }
    }

    if (kDebugMode) {
      // print('Request headers: ${response.request?.headers}');
      // print('SDK Facade Request: ${response.request}');
      // print('SDK Facade Response status: ${response.statusCode}');
      // print('SDK Facade Response body: ${response.body}');
    }
    return response;
  }
}
