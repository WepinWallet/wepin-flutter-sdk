import 'dart:collection';

class Account {
  final dynamic? _network;
  final dynamic? _address;

  Account(this._network, this._address);

  @override
  String toString() {
    return "{network=$_network, address = $_address}";
  }

  Account.fromJson(Map<dynamic, dynamic> json) :
        _network = json['network'],
        _address = json['address'];

  dynamic get address => _address;
  dynamic get network => _network;
}



