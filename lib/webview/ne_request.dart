class NERequest {
  NERequestHeader header;
  NERequestBody body;

  NERequest({required this.header, required this.body});

  Map<String, dynamic> toJson() {
    return {'header': header.toJson(), 'body': body.toJson()};
  }
}

class NERequestHeader {
  int id;
  String request_to;
  String request_from;

  NERequestHeader(
      {this.id = 4563140026900,
      this.request_to = 'wepin_widget',
      this.request_from = 'flutter'});

  Map<String, dynamic> toJson() {
    return {'id': id, 'request_to': request_to, 'request_from': request_from};
  }
}

class NERequestBody {
  String command;
  dynamic parameter;

  NERequestBody({required this.command, required this.parameter});

  Map<String, dynamic> toJson() {
    return {'command': command, 'parameter': parameter};
  }
}

class SetTokenParameter {
  String token;

  SetTokenParameter(this.token);

  Map<String, dynamic> toJson() {
    return {'token': token};
  }
}
