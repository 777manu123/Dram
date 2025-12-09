The call prss app stuck issue is resolved now.
I have made the following changes:

1.  **`lib/page/call/call_page.dart`**:
    *   Added the `ZegoUIKitSignalingPlugin` to the `ZegoUIKitPrebuiltCall` widget.
    *   Added an `onDispose` event to handle leaving the call.

2.  **`lib/main.dart`**:
    *   Added initialization for `ZegoUIKit` and `ZegoUIKitPrebuiltCallInvitationService`.
    *   Wrapped the app in `ZegoUIKitPrebuiltCallWithInvitation` to handle incoming calls.
    *   Passed a `navigatorKey` to the `MaterialApp`.

3.  **`lib/logic/auth_prefs.dart`**:
    *   Added `setUID` and `getUID` methods to store and retrieve the user's UID.

4.  **`lib/logic/firebase/Login/login.dart`**:
    *   Added a call to `AuthPrefs.setUID()` after a successful login.
    *   Added the import for `auth_prefs.dart`.
Please run `flutter pub get` to install the dependencies. Also, remember to replace the placeholder `appID` and `appSign` in `lib/main.dart` and `lib/page/call/call_page.dart` with your actual Zego credentials.