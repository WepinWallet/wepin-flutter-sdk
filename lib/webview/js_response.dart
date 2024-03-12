import 'package:wepin_flutter/webview/js_request.dart';
import 'package:wepin_flutter/wepin_inputs.dart';

class JSResponse {
  ResponseHeader header;
  ResponseBody body;

  JSResponse({required this.header, required this.body});

  Map<String, dynamic> toJson() {
    return {'header': header.toJson(), 'body': body.toJson()};
  }

  factory JSResponse.fromJson(Map<String, dynamic> json) {
    return JSResponse(
        header: ResponseHeader.fromJson(json['header']),
        body: ResponseBody.fromJson(json['body']));
  }
}

class ResponseHeader {
  int id;
  String reponse_from;
  String response_to;

  ResponseHeader(
      {required this.id,
      required this.reponse_from,
      required this.response_to});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'response_from': reponse_from,
      'response_to': response_to
    };
  }

  factory ResponseHeader.fromJson(Map<dynamic, dynamic> json) {
    return ResponseHeader(
        id: json['id'],
        reponse_from: json['response_from'],
        response_to: json['response_to']);
  }
}

class ResponseBody {
  String command;
  String state;
  dynamic data;

  ResponseBody(
      {required this.command, required this.state, required this.data});

  Map<String, dynamic> toJson() {
    return {'command': command, 'state': state, 'data': data};
  }

  factory ResponseBody.fromJson(Map<dynamic, dynamic> json) {
    return ResponseBody(
        command: json['command'], state: json['state'], data: json['data']);
  }
}

class ResponseReadyToWidget {
  String appKey;
  WidgetAttributes attributes;
  String domain;
  int platform;
  String version;
  String appId;

  ResponseReadyToWidget(this.appKey, this.attributes, this.domain,
      this.platform, this.version, this.appId);

  Map<String, dynamic> toJson() {
    return {
      'appKey': appKey,
      'attributes': attributes.toJson(),
      'domain': domain,
      'platform': platform,
      'version': version,
      'appId': appId
    };
  }
}
