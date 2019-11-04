import 'dart:io';
import 'package:alice/alice.dart';
import 'package:bar_ilan/blocs/bloc.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/dio.dart';
import 'wrapper.dart';

Future<void> main() async {
  return runApp(
    AppWrapper(
      await getApplicationDocumentsDirectory(),
      await SharedPreferences.getInstance(),
      await FlutterSecureStorage().read(key: "username"),
      await FlutterSecureStorage().read(key: "password"),
      alice: Alice(showNotification: true),
      // alice: (kReleaseMode) ? null : Alice(showNotification: true),
    ),
  );
}

class AppWrapper extends StatefulWidget {
  final Directory dir;
  final SharedPreferences prefs;
  final Alice alice;
  final Dio dio = Dio()..options.baseUrl = dioBaseUrl;
  final DioCacheManager cache = DioCacheManager(CacheConfig(baseUrl: dioBaseUrl));
  final String username;
  final String password;
  AppWrapper(this.dir, this.prefs, this.username, this.password,
      {this.alice});
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
    var res =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (res[PermissionGroup.storage] != PermissionStatus.granted) {
      if (await PermissionHandler()
          .shouldShowRequestPermissionRationale(PermissionGroup.storage)) {
        res = await PermissionHandler()
            .requestPermissions([PermissionGroup.storage]);
      }
    }
    widget.dio.interceptors.add(widget.alice.getDioInterceptor());
    widget.dio.interceptors.add(widget.cache.interceptor);
    // if (!kReleaseMode) {
    //   widget.dio.interceptors.add(widget.alice.getDioInterceptor());
    // } else {
    //   widget.dio.interceptors.add(DioCacheManager(CacheConfig(
    //     baseUrl: prefix0.baseUrl,
    //   )).interceptor);
    // }
    widget.dio.interceptors.add(
      CookieManager(
        (res[PermissionGroup.storage] == PermissionStatus.granted)
            ? PersistCookieJar(dir: widget.dir.path)
            : CookieJar(),
      ),
    );
    widget.dio.options.contentType = Headers.formUrlEncodedContentType;
    if (!widget.prefs.containsKey("isDark")) {
      widget.prefs.setBool("isDark", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Bloc>(
      builder: (_) => Bloc(widget.prefs, widget.dio, widget.cache, widget.dir,
          widget.username, widget.password,
          alice: widget.alice),
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
      // navigatorKey: (kReleaseMode)
      //     ? null
      //     : Provider.of<Bloc>(context).alice.getNavigatorKey(),
      navigatorKey: Provider.of<Bloc>(context).alice.getNavigatorKey(),
      theme: Provider.of<Bloc>(context).prefs?.getBool("isDark") ?? true
          ? ThemeData.dark()
          : ThemeData.light().copyWith(primaryColor: ThemeData.dark().primaryColor),
      home: MyApp(),
    );
  }
}
