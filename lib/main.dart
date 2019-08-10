import 'dart:io';
import 'package:alice/alice.dart';
import 'package:bar_ilan/blocs/bloc.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wrapper.dart';

Future<void> main() async {
  return runApp(
    AppWrapper(
      await getApplicationDocumentsDirectory(),
      await SharedPreferences.getInstance(),
      Dio(),
      alice: (kReleaseMode) ? null : Alice(showNotification: true),
    ),
  );
}

class AppWrapper extends StatefulWidget {
  final Directory dir;
  final SharedPreferences prefs;
  final Alice alice;
  final Dio dio;
  AppWrapper(this.dir, this.prefs, this.dio, {this.alice});
  @override
  _AppWrapperState createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    bootConfig();
    super.initState();
  }

  bootConfig() async {
    var res = await PermissionHandler()
        .requestPermissions([PermissionGroup.storage]);
    if (!kReleaseMode) {
      widget.dio.interceptors.add(widget.alice.getDioInterceptor());
    }
    else {
      widget.dio.interceptors.add(DioCacheManager(CacheConfig()).interceptor);
    }
    widget.dio.interceptors.add(
      CookieManager(
        (res[PermissionGroup.storage] == PermissionStatus.granted)
            ? PersistCookieJar(dir: widget.dir.path)
            : CookieJar(),
      ),
    );
    widget.dio.options.contentType =
        ContentType.parse("application/x-www-form-urlencoded");
    if (!widget.prefs.containsKey("isDark")) {
      widget.prefs.setBool("isDark", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Bloc>(
      builder: (_) => Bloc(widget.prefs, widget.dio, widget.dir, widget.alice),
      child: Wrapper(),
    );
  }
}

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        supportedLocales: [Locale('en'), Locale('he')],
        navigatorKey: (kReleaseMode) ? null : Provider.of<Bloc>(context).alice.getNavigatorKey(),
        theme: Provider.of<Bloc>(context).prefs?.getBool("isDark") ?? true ? ThemeData.dark() : ThemeData.light(),
        home: MyApp(),
      );
  }
}
