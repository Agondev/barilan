import 'package:bar_ilan/blocs/bloc.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as fss;
import 'package:html/parser.dart' as parser;
import 'package:provider/provider.dart';

// Global>>>
// __EVENTTARGET: ctl00$cmbActiveYear
// __EVENTTARGET: ctl00$ctl16
// __EVENTTARGET: ctl00$ctl17
// field>>>
// ctl00$cmbActiveYear: 2019

// pageSchedule>>>semester
// __EVENTTARGET: ctl00$tbMain$ctl03$ddlPeriodTypeFilter2
// ctl00$tbMain$ctl03$ddlPeriodTypeFilter2: 1
// ctl00$tbMain$ctl03$ddlPeriodTypeFilter2: 2
// ctl00$tbMain$ctl03$ddlPeriodTypeFilter2: 3

// exams>period (1: all, 2: future, 3: past)
// __EVENTTARGET: ctl00$tbMain$ctl03$ddlExamDateRangeFilter
// ctl00$tbMain$ctl03$ddlExamDateRangeFilter: 1
// all years
// ctl00$tbMain$ctl03$chkPersonalAssignmentTerms: on

const String baseUrl = "https://inbar.biu.ac.il/Live/";
const String pageLogin = "Login.aspx";
const String pageLogout = "Logout.aspx";
const String pageSchedule = "StudentPeriodSchedule.aspx";
const String pageGrades = "StudentGradesList.aspx";
const String pageTerms = "StudentAssignmentTermList.aspx";

const String argYear = r"ctl00$cmbActiveYear";
const String argEng = r"ctl00$ctl17";
const String argHeb = r"ctl00$ctl16";
const String argSemester = r"ctl00$tbMain$ctl03$ddlPeriodTypeFilter2";

Dio _dio;
BuildContext _context;
Response _response;
var _connectionErrorMessage = "Can't connect to inbar.biu.ac.il.";

String _username;
String _password;
String _event;
String _page;

var fields = Map<String, String>();

Future<Response> ping(BuildContext context,
    {String page = "", String event, bool refresh = false}) async {
  _dio = Provider.of<Bloc>(context).dio;
  _context = context;
  _event = event;
  _page = page;

  _username = Provider.of<Bloc>(context).username;
  _password = Provider.of<Bloc>(context).password;

  // buildExamQuery-->get> all periods> all years?> paging???

  if (!isLoggedIn()) {
    print("dio2");
    logIn();
    print("dio3");
  }

  try {
    if (_page.isEmpty) {
      print('dio1');
      _response = await _dio.get(baseUrl);
    }
  } on DioError catch (e) {
    print("dioError1");
    Provider.of<Bloc>(context).error =
        _connectionErrorMessage + "\n" + e.message;
    return null;
  }
  if (hasError()) {
    print("dioError2:" + _response.toString());
    return null;
  }

  if (_event == null) {
    print("dio4");
    _response = await _dio.get(
      baseUrl + page,
      options: buildCacheOptions(
        Duration(
          days: 7,
        ),
        primaryKey: baseUrl + page,
        maxStale: Duration(days: 180),
        forceRefresh: refresh,
      ),
    );
  } else {
    // ANCHOR onPost
    print("dio5");
    populateFields();
    _response = await _dio.post(
      baseUrl + page,
      data: fields,
      options: buildCacheOptions(
        Duration(days: 7),
        maxStale: Duration(days: 180),
      ),
    );
  }

  print("dio6");

  Provider.of<Bloc>(context).error = null;
  return _response;
}

void populateFields() {
  fields["edtUsername"] = _username;
  fields["edtPassword"] = _password;
  fields["__EVENTVALIDATION"] = parser
      .parse(_response?.data ?? "")
      ?.querySelector("#__EVENTVALIDATION")
      ?.attributes["value"];
  fields["__PageDataKey"] = parser
      .parse(_response?.data ?? "")
      ?.querySelector("#__PageDataKey")
      ?.attributes["value"];
  fields["__EVENTTARGET"] = _event;
  fields[r"ctl00$cmbActiveYear"] = _event;
  fields["tvMain_ExpandState"] = "nunnunnunnnnnunnnnnunununnnnnnnn";
  // fields["tvMain_SelectedNode"] = "tvMainn0";
  // fields["tvMain_SelectedNode"] = "tvMainn5";
}

Future<void> logIn() async {
  print("login1");
  populateFields();
  print("login2");
  try {
    _response = await _dio.post(
      baseUrl + pageLogin,
      data: fields,
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status < 500,
      ),
    );
    var valid = true;
    print("login3");
    parser.parse(_response.data).getElementsByTagName("script").forEach((e) {
      if (e.text.contains("OLScriptCounter0alert")) {
        Provider.of<Bloc>(_context).error = "Wrong username or password";
        valid = false;
      }
    });
    if (hasError() || !valid) {
      return null;
    }
    print("login4");
    fss.FlutterSecureStorage().write(key: "username", value: _username);
    fss.FlutterSecureStorage().write(key: "password", value: _password);
    _response = await _dio.get(baseUrl);
    // get information here.
    var yearsList = List<String>();
    print("login5");
    parser
        .parse(_response?.data)
        ?.querySelector("#cmbActiveYear")
        ?.children
        ?.forEach((f) {
      yearsList.add(f?.text);
    });
    print("login6");
    Provider.of<Bloc>(_context).prefs.setStringList("cmbActiveYear", yearsList);
    Provider.of<Bloc>(_context).fullName =
        parser.parse(_response?.data).querySelector("#lblUserFullName")?.text;
    print('dio_success');
  } on DioError catch (e) {
    Provider.of<Bloc>(_context).error =
        _connectionErrorMessage + "\n" + e.message;
    return null;
  } catch (e) {
    throw Exception(e);
  }
}

bool isLoggedIn() {
  if (_response?.data != null && parser.parse(_response?.data)?.getElementById("dvLoginPart") != null) {
    Provider.of<Bloc>(_context).isSignedIn = false;
    return false;
  }
  Provider.of<Bloc>(_context).isSignedIn = true;
  return true;
}

bool hasError() {
  if (_response == null) {
    print("dioError_res_null");
    return true;
  }
  if (parser.parse(_response.data).querySelector(".errorPagePanel") != null) {
    Provider.of<Bloc>(_context).error =
        // #lblDescription
        parser.parse(_response.data).querySelector(".errorPagePanel").text;
    return true;
  }
  return false;
}
