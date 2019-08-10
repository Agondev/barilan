import 'package:bar_ilan/blocs/bloc.dart';
import 'package:bar_ilan/models/schedule.dart';
import 'package:bar_ilan/utils/html2widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:html/parser.dart' as parser;
import 'package:bar_ilan/html.dart' as dom;

class ScheduleView extends StatefulWidget {
  @override
  _ScheduleViewState createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  Response res;
  List<Schedule> scheduleList;
  int selectedDay;

  @override
  void initState() {
    super.initState();

    // String eventTarget = r"ctl00$tbMain$ctl03$ddlPeriodTypeFilter2"; // semester 1, 2, 3
    // String year =  r"ctl00$cmbActiveYear: 2017" // POST

    scheduleList = Converter.scheduleList(parser
        .parse(dom.courses2016a)
        .querySelector("#ContentPlaceHolder1_gvPeriodSchedule")
        .children[0]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // If cached show old.
    // if logged in show data, else show message

    selectedDay = Provider.of<Bloc>(context).scheduleLastSelection ??
        DateTime.now().weekday;

    var filteredList =
        scheduleList.where((x) => x.dayOfWeek == selectedDay).toList();

    var children = filteredList
        .map(
          (f) => Container(
            color: f.meetingType == "Lecture"
                ? ((Theme.of(context).brightness == Brightness.dark)
                    ? Colors.green.withOpacity(.5)
                    : Colors.green[300])
                : ((Theme.of(context).brightness == Brightness.dark)
                    ? Colors.red.withOpacity(.5)
                    : Colors.red[300]),
            child: InkWell(
              onTap: () => showDialog(
                  context: context,
                  builder: (c) {
                    return SimpleDialog(
                      title: Center(
                        child: Column(
                          children: <Widget>[
                            Text(f.courseName),
                            Text(
                              f.teacher,
                              textScaleFactor: .75,
                            )
                          ],
                        ),
                      ),
                      children: [
                        ListTile(
                          title: Text("Code"),
                          trailing: Text(
                            f.courseCode,
                          ),
                        ),
                        ListTile(
                          title: Text("Building"),
                          trailing: Text(
                            f.building.toString(),
                          ),
                        ),
                        ListTile(
                          title: Text("Room"),
                          trailing: Text(
                            f.room.toString(),
                          ),
                        ),
                        ListTile(
                          title: Text("Type"),
                          trailing: Text(f.meetingType),
                        ),
                        ListTile(
                          title: Text("Yearly hours"),
                          trailing: Text(f.yearlyHours.toString()),
                        ),
                        ListTile(
                          title: Text("Points"),
                          trailing: Text(f.points.toString()),
                        ),
                        ListTile(
                          title: Text("Period"),
                          trailing: Text(f.period),
                        ),
                        ListTile(
                          title: Text("Status"),
                          trailing: Text(f.status == "\xA0" ? "???" : f.status),
                        ),
                        // ListTile(
                        //   title: Text("Syllabus"),
                        //   trailing: RaisedButton(
                        //     child: Text(f.link == null
                        //         ? "Unavailable"
                        //         : "Fetch"),
                        //     onPressed:
                        //         (f.link == null) ? null : () => null,
                        //   ),
                        // ),
                      ],
                    );
                  }),
              child: ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(f.startTime.format(context)),
                    Icon(Icons.arrow_downward),
                    Text(f.endTime.format(context)),
                  ],
                ),
                title: Text(f.courseName),
                subtitle: Text(f.teacher),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(f.building.toString()),
                    Icon(Icons.location_on),
                    Text(f.room.toString()),
                  ],
                ),
              ),
            ),
          ),
        )
        .toList();

    if (children.length == 0) {
      children.add(Container(
        child: ListTile(
          title: Text(
            "Nothing",
            textAlign: TextAlign.center,
          ),
        ),
      ));
    } else {
      for (var i = 0; i < filteredList.length - 1; i++) {
        if (filteredList[i].endTime != filteredList[i + 1].startTime) {
          children.insert(
            i + 1,
            Container(
              color: Colors.blue,
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(filteredList[i].endTime.format(context)),
                    Icon(Icons.chevron_right),
                    Text("Window"),
                    Icon(Icons.chevron_right),
                    Text(filteredList[i + 1].startTime.format(context))
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: ListView(
              children: children,
            ),
          ),
          GestureDetector(
            onHorizontalDragUpdate: (d) {
              if (d.delta.dx > 1 && d.delta.dx < 1.15) {
                setState(() {
                  if (selectedDay == 5) {
                    selectedDay = 7;
                  } else if (selectedDay == 7) {
                    selectedDay = 1;
                  } else {
                    selectedDay++;
                  }
                  Provider.of<Bloc>(context).scheduleLastSelection =
                      selectedDay;
                });
              } else if (d.delta.dx < -1 && d.delta.dx > -1.15) {
                setState(() {
                  if (selectedDay == 1) {
                    selectedDay = 7;
                  } else if (selectedDay == 7) {
                    selectedDay = 5;
                  } else {
                    selectedDay--;
                  }
                  Provider.of<Bloc>(context).scheduleLastSelection =
                      selectedDay;
                });
              }
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              height: 50,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.purple[800]
                  : Colors.pink,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  buildDayOfWeek(context, "Sun", 7),
                  buildDayOfWeek(context, "Mon", 1),
                  buildDayOfWeek(context, "Tue", 2),
                  buildDayOfWeek(context, "Wed", 3),
                  buildDayOfWeek(context, "Thu", 4),
                  buildDayOfWeek(context, "Fri", 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDayOfWeek(BuildContext context, String text, int weekday) {
    return SizedBox(
      width: 45,
      child: Center(
        child: FloatingActionButton(
          child: Text(text),
          onPressed: () {
            Provider.of<Bloc>(context).scheduleLastSelection = weekday;
            setState(() => selectedDay = weekday);
          },
          backgroundColor: selectedDay == weekday
              ? Colors.amber.withOpacity(.5)
              : Colors.transparent,
          foregroundColor:
              (scheduleList.where((x) => x.dayOfWeek == weekday).length == 0)
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).textTheme.body1.color,
          elevation: 0,
        ),
      ),
    );
  }
}
