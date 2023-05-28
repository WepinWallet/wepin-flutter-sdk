
class JSRequest{
  RequestHeader header;
  RequestBody body;

  JSRequest({
    required this.header,
    required this.body
  });

  factory JSRequest.fromJson(Map<String, dynamic> json){
    return JSRequest(
      header: RequestHeader.fromJson(json['header']),
      body: RequestBody.fromJson(json['body'])
    );
  }
}

class RequestHeader{
  int id;
  String request_to;
  String request_from;

  RequestHeader({
    this.id = 2678140026900,
    this.request_to = 'wepin_widget',
    required this.request_from
  });

  factory RequestHeader.fromJson(Map<dynamic, dynamic> json){
    return RequestHeader(
      id: json['id'],
      request_to: json['request_to'],
      request_from: json['request_from']
    );
  }
}

class RequestBody{
  String command;
  dynamic? parameter;

  RequestBody({
    required this.command,
    this.parameter
  });

  factory RequestBody.fromJson(Map<dynamic, dynamic> json){
    return RequestBody(
      command: json['command'],
      parameter : json['parameter']
    );
  }
}