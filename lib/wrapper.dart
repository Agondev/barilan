import 'package:bar_ilan/drawer.dart';
import 'package:bar_ilan/html.dart';
import 'package:bar_ilan/utils/html2widget.dart';
import 'package:bar_ilan/views/exams.dart';
import 'package:bar_ilan/views/grades.dart';
import 'package:bar_ilan/views/home.dart';
import 'package:bar_ilan/views/schedule.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'blocs/bloc.dart';
import 'package:html/parser.dart' as parser;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
            // (kReleaseMode)
            //     ? null :
            IconButton(
              icon: Icon(Icons.http),
              onPressed: () => Provider.of<Bloc>(context).alice.showInspector(),
            ),
            // (kReleaseMode)
            //     ? null :
            IconButton(
              icon: Icon(Icons.settings_applications),
              onPressed: () => PermissionHandler().openAppSettings(),
            )
          ],
          bottom: TabBar(tabs: tabs),
        ),
        body: TabBarView(
          children: <Widget>[
            HomeView(),
            // FutureBuilder(
            //   future: ping(context, page: pageSchedule),
            //   builder: (context, snap) =>
            //       (snap.connectionState == ConnectionState.done)
            //           ? ScheduleView(
            //               Converter.scheduleList(
            //                 parser
            //                     .parse(snap.data.toString())
            //                     .querySelector(".GridView")
            //                     .children[0],
            //               ),
            //             )
            //           : RefreshProgressIndicator(),
            // ),
            ScheduleView(
              Converter.scheduleList(
                  parser
                      .parse(courses2019a)
                      .querySelector(".GridView")
                      .children[0],
                ),
            ),
            GradesView(),
            ExamsView(
              Converter.examList(
                parser.parse(exams2020).querySelector(".GridView").children[0],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
