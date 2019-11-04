import 'package:bar_ilan/blocs/bloc.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart' as fss;
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

enum DioEvent {
  NoUsernameOrPassword,
  DioError,
  OrbitError,
  WrongUsernameOrPassword,
  Logout,
}

const String dioBaseUrl = "https://inbar.biu.ac.il/Live/";
const String dioPageLogin = "Login.aspx";
const String dioPageLogout = "Logout.aspx";
const String dioPageSchedule = "StudentPeriodSchedule.aspx";
const String dioPageGrades = "StudentGradesList.aspx";
const String dioPageTerms = "StudentAssignmentTermList.aspx";

const String dioArgYear = r"ctl00$cmbActiveYear";
const String dioArgEng = r"ctl00$ctl17";
const String dioArgHeb = r"ctl00$ctl16";
const String dioArgSemester = r"ctl00$tbMain$ctl03$ddlPeriodTypeFilter2";

Dio _dio;
BuildContext _context;
Response _response;
var _connectionErrorMessage = "Can't connect to " + dioBaseUrl;

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

  if (_username == null || _password == null) {
    Provider.of<Bloc>(_context).error =
        DioEvent.NoUsernameOrPassword.toString();
    return Response(data: DioEvent.NoUsernameOrPassword);
  }

  // _username != null ? print("dioUsername: "+_username) : print("dioNoUsername");
  // _username != null ? print("dioPassword: "+_password) : print("dioNoPassword");
  // print("dioPage: "+_page);

  // buildExamQuery-->get> all periods> all years?> paging???

  if (page == dioPageLogout) {
    Provider.of<Bloc>(context).isSignedIn = false;
    Provider.of<Bloc>(context).error = DioEvent.Logout.toString();
    return Response(data: DioEvent.Logout);
  }

  if (!_isLoggedIn()) {
    print("dioIsLoggedInBefore");
    _logIn();
    print("dioIsLoggedInAfter");
  }

  try {
    if (_page.isEmpty) {
      print('dio1');
      _response = await _dio.get("");
    }
  } on DioError catch (e) {
    print("dioError1");
    Provider.of<Bloc>(context).error =
        _connectionErrorMessage + "\n" + e.message;
    return Response(data: DioEvent.DioError);
  }

  if (_hasError()) {
    print("dioError2:" + _response.toString());
    return Response(data: DioEvent.OrbitError);
  }

  if (_event == null) {
    print("dio4");
    _response = await _dio.get(
      page,
      options: buildCacheOptions(
        Duration(
          days: 7,
        ),
        maxStale: Duration(days: 180),
        forceRefresh: refresh,
      ),
    );
  } else {
    // ANCHOR onPost
    print("dio5");
    _populateFields();
    _response = await _dio.post(
      page,
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

void _populateFields() {
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

Future<void> _logIn() async {
  print("login1");
  _populateFields();
  print("login2");
  try {
    _response = await _dio.post(
      dioPageLogin,
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
        valid = false;
      }
    });
    if (!valid) {
      Provider.of<Bloc>(_context).error =
          DioEvent.WrongUsernameOrPassword.toString();
      return Response(data: DioEvent.WrongUsernameOrPassword);
    }
    if (_hasError()) {
      return Response(data: DioEvent.OrbitError);
    }
    print("login4");
    // fss.FlutterSecureStorage().write(key: "username", value: _username);
    // fss.FlutterSecureStorage().write(key: "password", value: _password);
    _response = await _dio.get("");
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
    return Response(data: DioEvent.DioError);
  } catch (e) {
    throw Exception(e);
  }
}

bool _isLoggedIn() {
  print("dioMethod_IsLoggedIn_Before");
  if (_response?.data != null &&
      parser.parse(_response?.data)?.getElementById("dvLoginPart") != null) {
    print("dioMethod_IsLoggedIn_Middle");
    print("res.data: " + _response.data);
    Provider.of<Bloc>(_context).isSignedIn = false;
    return false;
  }
  print("dioMethod_IsLoggedIn_After");
  Provider.of<Bloc>(_context).isSignedIn = true;
  return true;
}

bool _hasError() {
  Provider.of<Bloc>(_context).isSignedIn = false;
  if (_response == null) {
    print("dioError_res_null");
    return true;
  } else if (parser.parse(_response.data).querySelector(".errorPagePanel") !=
      null) {
    Provider.of<Bloc>(_context).error =
        // #lblDescription
        parser.parse(_response.data).querySelector(".errorPagePanel").text;
    return true;
  } else {
    Provider.of<Bloc>(_context).error = DioEvent.OrbitError.toString();
    Provider.of<Bloc>(_context).isSignedIn = true;
  }
  return false;
}
