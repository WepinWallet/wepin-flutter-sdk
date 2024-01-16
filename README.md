# wepin-flutter-sdk
Wepin Flutter SDK for Android OS and iOS
<br />

## ⏩ Get App ID and Key

Contact to wepin.contact@iotrust.kr

## ⏩ Install

### wepin-flutter-sdk
Add a dependency 'wepin_flutter' in your pubspec.yaml file.

```xml
dependencies:
  wepin_flutter: ^0.0.3
```
or

```xml
flutter pub add wepin_flutter
```

## ⏩ Add Permission for Android

Add the below line in your app's `AndroidMainfest.xml` file
```xml
<uses-permission android:name="android.permission.INTERNET" />
```
## ⏩ Config Deep Link

Deep link scheme format: Your app package name or bundle id + '.wepin'

### For Android

Add the below line in your app's `AndroidMainfest.xml` file

```xml
<activity
    android:name=".MainActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <!--For Deep Link => Urlscheme Format : packageName + .wepin-->
        <data
            android:scheme="com.sample.app.wepin"
            />
    </intent-filter>
</activity>
```

### For iOS

Add the URL scheme as below:

1. Open your iOS project with the xcode
2. Click on Project Navigator
3. Select Target Project in Targets
4. Select Info Tab
5. Click the '+' buttons on URL Types
6. Enter Identifier and URL Schemes
   - Idenetifier: bundle id of your project
   - URL Schems: bundle id of your project + '.wepin'
     
  ![스크린샷 2024-01-16 오후 6 27 08](https://github.com/WepinWallet/wepin-flutter-sdk/assets/43332708/8bf25d18-5aef-4767-88e3-f61d10272c64)
   


## ⏩ Import SDK 
```dart
import 'package:wepin_flutter/wepin.dart';
import 'package:wepin_flutter/wepin_delegate.dart';
import 'package:wepin_flutter/wepin_inputs.dart';
import 'package:wepin_flutter/wepin_outputs.dart';
```

## ⏩ Initialize

- Create Wepin instance
```dart
Wepin _wepin = Wepin();
```
- Add method in your app's 'initState()' for Handing Deeplink 
```dart
import 'package:uni_links/uni_links.dart';
....

class _SampleApp extends State<SampleApp> {
  StreamSubscription? _sub;
  final String _appId = 'test_app_id';
  final String _appSdkKey =
      'test_app_key';

  @override
  void initState() {
    if (kDebugMode) {
      print('initState');
    }
    super.initState();

    _wepin = Wepin();
    _handleDeepLink(); 
  }
....

// Handle incoming links - the ones that the app will recieve from the OS
// while already started.

  void _handleDeepLink() {
    if (kDebugMode) {
      print('_handleDeepLink');
    }
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        if (kDebugMode) {
          print('got_uri: $uri');
        }
        _wepin.handleWepinLink(uri!);
      }, onError: (Object err) {
        if (!mounted) return;
        if (kDebugMode) {
          print('got_err: $err');
        }
      });
    }
  }
```

- Add Event Listener

In order to implement a listener for handling events that occur when an error occurs in the Wepin widget or when an account is created after a successful login, 
you can inherit the WepinDelegate as follows.

```dart
class SampleApp extends StatefulWidget with WepinDelegate {
  SampleApp({super.key});

  @override
  _SampleApp createState() => _SampleApp();

  @override
  void onWepinError(String errMsg) {
    // TODO: implement onWepinError
    if (kDebugMode) {
      print('onWepinError : $errMsg');
    }
  }

  @override
  void onAccountSet() {
    // TODO: implement onAccountSet
    if (kDebugMode) {
      print('onAccountSet');
    }
    List<Account>? accounts = _wepin.getAccounts();
    if (accounts == null) {
      if (kDebugMode) {
        print('accounts is null');
      }
      return;
    }
    for (var account in accounts!) {
      if (kDebugMode) {
        print('netwrok : ${account.network}');
        print('address : ${account.address}');
      }
    }
  }
}
```


## ⏩ Methods

Methods of Wepin SDK.

### Initialize
```dart
void initialize(BuildContext appContext, WepinOptions wepinOptions)
```
This method initializing Wepin SDK. If success, Wepin widget will show login page.
#### Parameters

- `appContext` \<BuildContext> : context of your app
- `wepinOptions` \<WepinOptions>
  - `appId` \<String>
  - `appKey` \<String>
  - `widgetAttributes` \<WidgetAttributes>
      - defaultLanguage<String>: The language to be displayed on the widget (default: 'ko')
        - Currently, only 'ko' and 'en' are supported.
      - defaultCurrency<String>: The currency to be displayed on the widget (default: 'krw')
  
#### Example

```dart
    WidgetAttributes widgetAttributes = WidgetAttributes('ko', 'krw');
    WepinOptions wepinOptions =
        WepinOptions(_appId, _appSdkKey, widgetAttributes);
    _wepin.initialize(context, wepinOptions);
```

### isInitialized

```dart
bool isInitialized()
```

This method checks Wepin SDK is initialized.

#### Return value

- \<bool>
  - `true` if Wepin SDK is already initialized.

### openWidget

```dart
void openWidget()
```

This method shows Wepin widget. 

### closeWidget

```dart
void closeWidget()
```

This method closes Wepin widget.

### getAccounts

```dart
List<Account>? getAccounts()
```

This method returns user's accounts. If user is not logged in, Wepin widget will be opened and show login page. 

#### Return value

- If user is logged in, it returns list of `user's account`
  - `account` \<Account>
    - `network` \<dynamic>
    - `address` \<dynamic>

- If user is not logged in, it returns null

### finalize

```dart
void finalize()
```

This method finalize Wepin widget.
