import 'package:bar_ilan/blocs/bloc.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:html/parser.dart' as parser;
import 'package:provider/provider.dart';

var connectionErrorMessage = "Check your internet connection. Details:";
String urlLogin = "/Login.aspx";

Future<Response> ping(BuildContext context,
    {String username,
    String password,
    String page,
    String event,
    int year}) async {
  year = DateTime.now().year;
  Dio dio = Provider.of<Bloc>(context).dio;
  String url = Provider.of<Bloc>(context).url;
  Response res;
  var fields = Map<String, String>();
  try {
    if (page == null) {
      res = await dio.get(url);
    } else {
      if (event == null) {
        res = await dio.get(
          url + page,
          options: buildCacheOptions(
            Duration(
              days: 1,
            ),
            maxStale: Duration(days: 180),
          ),
        );
      } else {
        fields["__EVENTVALIDATION"] = parser
            .parse(res?.data ?? "")
            ?.querySelector("#__EVENTVALIDATION")
            ?.attributes["value"];
        fields["__EVENTTARGET"] = event;
        res = await dio.post(url + page, data: fields);
      }
    }
  } on DioError catch (e) {
    Provider.of<Bloc>(context).error =
        connectionErrorMessage + "\n" + e.message;
    return null;
  }
  if (hasOrbitError(context, res)) {
    return null;
  }
  //ANCHOR OnLogin
  if (parser.parse(res.data).getElementById("dvLoginPart") != null &&
      username != null &&
      password != null) {
    fields["edtUsername"] = username;
    fields["edtPassword"] = password;
    try {
      fields["__EVENTVALIDATION"] = parser
          .parse(res?.data ?? "")
          ?.querySelector("#__EVENTVALIDATION")
          ?.attributes["value"];
      fields["__PageDataKey"] = parser
          .parse(res?.data ?? "")
          ?.querySelector("#__PageDataKey")
          ?.attributes["value"];

      res = await dio.post(
        url + urlLogin,
        data: fields,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status < 500,
        ),
      );
      var valid = true;
      parser.parse(res.data).getElementsByTagName("script").forEach((e) {
        if (e.text.contains("OLScriptCounter0alert")) {
          Provider.of<Bloc>(context).error = "Wrong username or password";
          valid = false;
          return;
        }
      });
      if (hasOrbitError(context, res) || !valid) {
        return null;
      }
      FlutterSecureStorage().write(key: "username", value: username);
      FlutterSecureStorage().write(key: "password", value: password);
      res = await dio.get(url);
      // get information here.
      var yearsList = List<String>();
      parser
          .parse(res?.data)
          .querySelector("#cmbActiveYear")
          .children
          .forEach((f) {
        yearsList.add(f.text);
      });
      Provider.of<Bloc>(context).signedIn = true;
      Provider.of<Bloc>(context)
          .prefs
          .setStringList("cmbActiveYear", yearsList);
      Provider.of<Bloc>(context).fullName =
          parser.parse(res?.data).querySelector("#lblUserFullName").text;
    } on DioError catch (e) {
      Provider.of<Bloc>(context).error =
          connectionErrorMessage + "\n" + e.message;
      return null;
    } catch (e) {
      throw Exception(e);
    }
  }

  // build POST request with __EVENTTARGET (language)
  // Hebrew ctl00$ctl16
  // English ctl00$ctl17

  // GET main > https://inbar.biu.ac.il/Live/Main.aspx

  // ctl00$cmbActiveYear
  // scrape years: #cmbActiveYear > option

  if (year != DateTime.now().year) {}

  Provider.of<Bloc>(context).error = "";
  return res;
}

bool hasOrbitError(BuildContext context, Response res) {
  if (parser.parse(res.data).querySelector(".errorPagePanel") != null) {
    Provider.of<Bloc>(context).error =
        parser.parse(res.data).querySelector(".errorPagePanel").text;
    return true;
  }
  return false;
}
