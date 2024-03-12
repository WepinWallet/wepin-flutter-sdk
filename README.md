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
  wepin_flutter: ^0.0.4
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

Deep link scheme format: 'wepin.' + Your App ID

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
        <!--For Deep Link => Urlscheme Format : wepin. + appID-->
        <data
            android:scheme="wepin.88889999000000000000000000000000"
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
   - URL Schems: 'wepin.' + Your App ID
     
  ![스크린샷 2024-01-16 오후 6 27 08](https://github.com/WepinWallet/wepin-flutter-sdk/assets/43332708/8bf25d18-5aef-4767-88e3-f61d10272c64)
   


## ⏩ Import SDK 
```dart
import 'package:wepin_flutter/wepin.dart';
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

## ⏩ Methods

Methods of Wepin SDK.

### Initialize
```dart
Future<void> initialize(BuildContext appContext, WepinOptions wepinOptions)
```
This method initializing Wepin SDK.
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
    _wepin.initialize(context, wepinOptions)
```

### isInitialized

```dart
bool isInitialized()
```

This method checks Wepin SDK is initialized.

#### Example

```dart
    _wepin.isInitialized()
```

#### Return value

- \<bool>
  - `true` if Wepin SDK is already initialized.

### openWidget

```dart
void openWidget()
```

This method shows Wepin widget

#### Example

```dart
    _wepin.openWidget()
```

### closeWidget

```dart
void closeWidget()
```

This method closes Wepin widget.

#### Example

```dart
    _wepin.closeWidget()
```

### getAccounts

```dart
List<Account>? getAccounts()
```

This method returns user's accounts. 

#### Example

```dart
    _wepin.getAccounts()
```

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

#### Example

```dart
    _wepin.finalize()
```

### getStatus (Support from version 0.0.4-alpha)

```dart
Future<String> getStatus()
```

The method returns lifecycle of wepin.

#### Example

```dart
   await _wepin.getStatus()
```

#### Return value

- WepinLifeCycle
    - `not_initialized`: if wepin is not initialized
    - `initializing`: if wepin is initializing
    - `initialized`: if wepin is initialized
    - `before_login`: if wepin is initialized but the user is not logged in
    - `login`: if the user is logged in

### login (Support from version 0.0.4-alpha)

```dart
Future<WepinUser> login()
```

This method returns information of the logged-in user. If a user is not logged in, Wepin widget will show login page.

#### Example

```dart
   await _wepin.login()
```

#### Return value

- WepinUser
  - `status` \<String> \<'success'|'fail'>
  - `UserInfo?` 
    - `userId` \<dynamic>
    - `email` \<dynamic>
    - `provider` \<dynamic> \<'google'|'apple'|'email'|'naver'|'discord'|'external_token'>


### getSignForLogin (Support from version 0.0.4-alpha)

This method signs the idToken received after logging in with OAuth using a PrivateKey. 

```dart
String getSignForLogin(String privKey, String idToken)
```
#### Example

```dart
     _wepin.getSignForLogin(_testPrivKey, _testIdToken);
```

#### Parameters

- `privKey` <String>
  - PrivateKey for signning idToken
- `idToken` <String>
  - External token value to be used for login (e.g., idToken).

#### Return value

- signned token <String>
  -You can log in with the loginWithExternalToken function using this.

### loginWithExternalToken (Support from version 0.0.4-alpha)

This method logs in to the Wepin with external token(e.g., idToken). 

```dart
Future<WepinUser> loginWithExternalToken(String idToken, String sign)
```
#### Example

```dart
     await _wepin.loginWithExternalToken(_testIdToken, _testSignedIdToken)
```

#### Parameters

- `idToken` <String>
  - External token value to be used for login (e.g., idToken).
- `sign` <String>
  - The token value signed with the getSignForLogin() method.

#### Return value

- WepinUser
  - `status` \<String> \<'success'|'fail'>
  - `UserInfo?` 
    - `userId` \<dynamic>
    - `email` \<dynamic>
    - `provider` \<dynamic> \<'google'|'apple'|'email'|'naver'|'discord'|'external_token'>

### logout (Support from version 0.0.4-alpha)

performs logout for wepin

```dart
Future<void> logout()
```

#### Example

```dart
   await _wepin.logout()
```
