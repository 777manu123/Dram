import 'package:shared_preferences/shared_preferences.dart';

class AuthPrefs {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> setAutoLogin(bool v) async {
    await init();
    await _prefs!.setBool('autoLogin', v);
  }

  static Future<bool> isAutoLogin() async {
    await init();
    return _prefs!.getBool('autoLogin') ?? false;
  }

  static Future<void> setLastEmail(String email) async {
    await init();
    await _prefs!.setString('lastEmail', email);
  }

  static Future<String?> getLastEmail() async {
    await init();
    return _prefs!.getString('lastEmail');
  }

  static Future<void> setUID(String uid) async {
    await init();
    await _prefs!.setString('uid', uid);
  }

  static String getUID() {
    return _prefs?.getString('uid') ?? '';
  }
}
