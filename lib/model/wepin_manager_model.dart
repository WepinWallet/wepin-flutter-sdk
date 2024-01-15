import '../wepin_outputs.dart';

class WepinManagerModel {
  List<Account>? _accountList;
  late bool _isInitialized;
  late String _appUniqueId;

  static final WepinManagerModel _instance = WepinManagerModel._internal();

  // singleton
  factory WepinManagerModel() => _instance;

  WepinManagerModel._internal() {
    _isInitialized = false;
    _accountList = null;
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

  void setAppUniqueId(String uniqueId) {
    _appUniqueId = uniqueId;
  }

  String getAppUniqueId() {
    return _appUniqueId;
  }
}
