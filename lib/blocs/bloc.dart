import 'dart:io';
import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bloc with ChangeNotifier{
  Bloc(this._preferences, this._dio, this._cache, this._dir, this.username, this.password, {this.alice});

  Directory _dir;
  Dio _dio;
  DioCacheManager _cache;
  Alice alice;
  SharedPreferences _preferences;

  String _fullName = "Sign In";
  String username;
  String password;
  String eventValidation;
  String eventTarget;
  String error;
  Response response;
  bool _isSignedIn = false;

  int scheduleLastSelection;

  SharedPreferences get prefs => _preferences;
  Dio get dio => _dio;
  DioCacheManager get cache => _cache;
  Directory get dir => _dir;

  bool get isSignedIn => _isSignedIn;
  
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

  set isSignedIn(bool val) {
    _isSignedIn = val;
    notifyListeners();
  }

  set fullName(String fn) {
    _preferences.setString("fullName", fn);
  }

  set theme(bool isDark) {
    _preferences.setBool("isDark", isDark);
    notifyListeners();
  }
  
  set isEng(bool isEng) {
    _preferences.setBool("isEng", isEng);
    notifyListeners();
  }
}