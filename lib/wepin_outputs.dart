class Account {
  final dynamic _network;
  final dynamic _address;

  Account(this._network, this._address);

  @override
  String toString() {
    return "{network=$_network, address = $_address}";
  }

  Account.fromJson(Map<dynamic, dynamic> json)
      : _network = json['network'],
        _address = json['address'];

  dynamic get address => _address;
  dynamic get network => _network;
}

class UserInfo {
  final dynamic _userId;
  final dynamic _email;
  final dynamic _provider;

  UserInfo(this._userId, this._email, this._provider);

  UserInfo.fromJson(Map<dynamic, dynamic> json)
      : _userId = json['userId'],
        _email = json['email'],
        _provider = json['provider'];

  Map<String, dynamic> toJson() {
    return {
      'userId': _userId,
      'email': _email,
      'provider': _provider,
    };
  }

  dynamic get userId => _userId;
  dynamic get email => _email;
  dynamic get provider => _provider;
}

class WepinUser {
  final String _status;
  final UserInfo? _userInfo;

  WepinUser(this._status, this._userInfo);

  WepinUser.fromJson(Map<dynamic, dynamic> json)
      : _status = json['status'],
        _userInfo = json['userInfo'] != null
            ? UserInfo.fromJson(json['userInfo'])
            : null;

  Map<String, dynamic> toJson() {
    return {
      'status': _status,
      'userInfo': _userInfo != null ? _userInfo!.toJson() : null,
    };
  }

  dynamic get status => _status;
  dynamic get userInfo => _userInfo;
}
