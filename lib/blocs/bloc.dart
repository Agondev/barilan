import 'dart:io';
import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bloc with ChangeNotifier{
  Bloc(this._preferences, this._dio, this._dir, this._alice,);

  Directory _dir;
  Dio _dio;
  Alice _alice;
  SharedPreferences _preferences;
  String _url = "https://inbar.biu.ac.il/Live";

  String _fullName = "Sign In";
  String username;
  String password;
  String eventValidation;
  String eventTarget;
  String error;
  Response response;
  bool signedIn = false;

  int scheduleLastSelection;

  // String get username => _username;
  // String get password => _password;
  SharedPreferences get prefs => _preferences;
  Dio get dio => _dio;
  String get url => _url;
  Alice get alice => _alice;
  Directory get dir => _dir;
  bool get isDarkTheme {
    if (_preferences.containsKey("isDark")) {
      _preferences.getBool("isDark");
    }
    return true;
  }
  bool get isEng {
    if (_preferences.containsKey("isEng")) {
      return _preferences.getBool("isEng");
    }
    return true;
  }
  String get fullName {
    if (prefs.containsKey("fullName")) {
      return prefs.getString("fullName");
    }
    return _fullName;
  }

  set fullName(String fn) {
    _preferences.setString("fullName", fn);
  }

  set theme(bool isDark) {
    _preferences.setBool("isDark", isDark);
    notifyListeners();
  }
  
  set lang(bool isEng) {
    _preferences.setBool("isEng", isEng);
    notifyListeners();
  }
}