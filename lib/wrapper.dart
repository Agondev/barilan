import 'package:bar_ilan/drawer.dart';
import 'package:bar_ilan/utils/dio.dart';
import 'package:bar_ilan/views/exams.dart';
import 'package:bar_ilan/views/grades.dart';
import 'package:bar_ilan/views/home.dart';
import 'package:bar_ilan/views/schedule.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'blocs/bloc.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String result;
  String username;
  String password;
  String userFullName = "Logged out";
  String urlScheduleList = "/StudentPeriodSchedule.aspx";
  String urlScheduleTable = "/StudentMatrixPeriodSchedule.aspx";
  // #lblUserFullName > logged in
  // ctl00$tbMain$ctl03$ddlPeriodTypeFilter2 val:[1,2,3] (Semester)
  // POST ctl00$ctl16 (hebrew)
  // POST ctl00$ctl17 (english)
  // POST __EVENTTARGET ctl11 (Hebrew)
  // POST __EVENTTARGET ctl12 (English)
  // __EVENTTARGET: GET ctl00$cmbActiveYear (YYYY)

  @override
  void initState() {
    super.initState();
    () async {
      username = await FlutterSecureStorage().read(key: "username");
      password = await FlutterSecureStorage().read(key: "password");
      if (username != null && password != null) {
        ping(context, username: username, password: password);
      }
    }();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tabs = <Widget>[
      Tab(
        icon: Icon(Icons.home),
        text: "Home",
      ),
      Tab(
        icon: Icon(Icons.calendar_today),
        text: "Schedule",
      ),
      Tab(
        icon: Icon(Icons.show_chart),
        text: "Grades",
      ),
      Tab(
        icon: Icon(Icons.assignment),
        text: "Exams",
      ),
    ];
    return DefaultTabController(
      length: 4,
      initialIndex: 0,
      child: Scaffold(
        drawer: MyDrawer(),
        appBar: AppBar(
          title: Text("Home"),
          centerTitle: true,
          actions: <Widget>[
            (kReleaseMode)
                ? null
                : IconButton(
                    icon: Icon(Icons.http),
                    onPressed: () =>
                        Provider.of<Bloc>(context).alice.showInspector(),
                  ),
            (kReleaseMode)
                ? null
                : IconButton(
                    icon: Icon(Icons.settings_applications),
                    onPressed: () => PermissionHandler().openAppSettings(),
                  )
          ],
          bottom: TabBar(tabs: tabs),
        ),
        body: TabBarView(
          children: <Widget>[
            HomeView(),
            ScheduleView(),
            GradesView(),
            ExamsView(),
          ],
        ),
      ),
    );
  }
}
