import 'package:bar_ilan/blocs/bloc.dart';
import 'package:bar_ilan/models/schedule.dart';
import 'package:bar_ilan/utils/style.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ScheduleView extends StatefulWidget {
  final List<Schedule> scheduleList;

  ScheduleView(this.scheduleList);

  @override
  _ScheduleViewState createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  Response res;
  int selectedDay;
  double swipeInitial;
  double swipeDistance;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool showMsg = false;
  int _activeIndex;

  void _onRefresh() async {
    Future.delayed(Duration(seconds: 1));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed((Duration(seconds: 1)));
    setState(() {});

    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    // If cached show old.
    // if logged in show data, else show message

    Widget buildTile(String title, String trailing,
        {int building, String type, bool isRoom = false}) {
      Color color = Theme.of(context).canvasColor;
      if (building != null) {
        color = building2color(building).withOpacity(.5);
      } else if (type != null) {
        color = meetingType2Color(type).withOpacity(.5);
      } else if (isRoom) {
        color = Colors.red.withOpacity(.25);
      }
      return Container(
        color: Theme.of(context).canvasColor,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          color: color,
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(
                  color: (Theme.of(context).brightness == Brightness.dark)
                      ? Colors.white
                      : Colors.black),
            ),
            trailing: Text(
              trailing,
              style: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark)
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            dense: true,
          ),
        ),
      );
    }

    selectedDay = Provider.of<Bloc>(context).scheduleLastSelection ??
        DateTime.now().weekday;

    var filteredList =
        widget.scheduleList.where((x) => x.dayOfWeek == selectedDay).toList();

    Widget buildDayOfWeek(String text, int weekday) {
      return SizedBox(
        width: 45,
        child: Center(
          child: FloatingActionButton(
              heroTag: "DayOfWeekFAB" + weekday.toString(),
              child: Text(
                text,
                textScaleFactor: (selectedDay != weekday) ? .9 : 1.1,
              ),
              onPressed: () {
                Provider.of<Bloc>(context).scheduleLastSelection = weekday;
                setState(() {
                  selectedDay = weekday;
                  _activeIndex = null;
                });
              },
              backgroundColor:
                  selectedDay == weekday ? Colors.amber : Colors.transparent,
              foregroundColor: (widget.scheduleList
                          .where((x) => x.dayOfWeek == weekday)
                          .length ==
                      0)
                  ? (selectedDay == weekday
                      ? Colors.black45
                      : Theme.of(context).disabledColor)
                  : (selectedDay == weekday ? Colors.black : Colors.white),
              elevation: 0),
        ),
      );
    }

    // #region build tree
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              physics: filteredList.length == 0
                  ? NeverScrollableScrollPhysics()
                  : null,
              header: WaterDropMaterialHeader(),
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: (filteredList.length != 0)
                  ? ListView.separated(
                      itemCount: filteredList.length,
                      separatorBuilder: (context, idx) {
                        for (var i = 0; i < filteredList.length - 1; i++) {
                          if (filteredList[i].endTime !=
                              filteredList[i + 1].startTime) {
                            return Container(
                              color: Colors.blue[800],
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      filteredList[i].endTime.format(context),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "Window",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Icon(Icons.chevron_right,
                                        color: Colors.white),
                                    Text(
                                      filteredList[i + 1]
                                          .startTime
                                          .format(context),
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                        }
                        return Container();
                      },
                      itemBuilder: (context, idx) {
                        return Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    building2color(filteredList[idx].building),
                                    meetingType2Color(
                                        filteredList[idx].meetingType)
                                  ],
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  stops: [.1, .5])),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              cardColor: Colors.transparent,
                              disabledColor: Colors.white,
                              textTheme: TextTheme(
                                  body1: TextStyle(color: Colors.white)),
                            ),
                            child: ExpansionPanelList(
                              expansionCallback: (c, i) => setState(() {
                                _activeIndex = _activeIndex == idx ? null : idx;
                              }),
                              children: [
                                ExpansionPanel(
                                  canTapOnHeader: true,
                                  isExpanded: _activeIndex == idx,
                                  headerBuilder: (context, i) {
                                    return ListTile(
                                      leading: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(filteredList[idx]
                                              .startTime
                                              .format(context)),
                                          Icon(
                                            Icons.arrow_downward,
                                            color: Colors.white,
                                          ),
                                          Text(filteredList[idx]
                                              .endTime
                                              .format(context)),
                                        ],
                                      ),
                                      title: Container(
                                        margin: EdgeInsets.only(right: 25),
                                        child:
                                            Text(filteredList[idx].courseName),
                                      ),
                                      subtitle: Text(
                                          (filteredList[idx].teacher != "")
                                              ? filteredList[idx].teacher
                                              : "TBD"),
                                      trailing: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(filteredList[idx]
                                                .building
                                                .toString()),
                                            Icon(
                                              Icons.location_on,
                                              color: Colors.white,
                                            ),
                                            Text(filteredList[idx]
                                                .room
                                                .toString()),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  body: Column(
                                    children: <Widget>[
                                      buildTile(
                                          "Type", filteredList[idx].meetingType,
                                          type: filteredList[idx].meetingType),
                                      buildTile("Building",
                                          filteredList[idx].building.toString(),
                                          building: filteredList[idx].building),
                                      buildTile("Room",
                                          filteredList[idx].room.toString(),
                                          isRoom: true),
                                      buildTile(
                                        "Code",
                                        filteredList[idx].courseCode,
                                      ),
                                      buildTile(
                                        "Yearly hours",
                                        filteredList[idx]
                                            .yearlyHours
                                            .toString(),
                                      ),
                                      buildTile(
                                        "Points",
                                        filteredList[idx].points.toString(),
                                      ),
                                      buildTile(
                                        "Period",
                                        filteredList[idx].period,
                                      ),
                                      buildTile(
                                        "Status",
                                        filteredList[idx].status == "\xA0"
                                            ? "Unknown"
                                            : filteredList[idx].status,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Stack(
                      children: <Widget>[
                        Ink.image(
                          image: AssetImage("assets/rick_n_morty.png"),
                          alignment: Alignment(-.2, 0),
                          fit: BoxFit.cover,
                          child: InkWell(
                            onLongPress: () {
                              setState(() {
                                showMsg = !showMsg;
                              });
                              Future.delayed(Duration(milliseconds: 4000),
                                  () => setState(() => showMsg = !showMsg));
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              child: Text(
                                showMsg
                                    ? "Glorious freedom!"
                                    : "Nothing to see here",
                                textScaleFactor: 2,
                              ),
                              style: !showMsg
                                  ? TextStyle(color: Colors.transparent)
                                  : TextStyle(color: Colors.white),
                              duration: const Duration(milliseconds: 5000),
                              curve: Curves.bounceInOut,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          GestureDetector(
            onHorizontalDragStart: (DragStartDetails d) =>
                swipeInitial = d.globalPosition.dx,
            onHorizontalDragUpdate: (DragUpdateDetails d) =>
                swipeDistance = d.globalPosition.dx - swipeInitial,
            onHorizontalDragEnd: (DragEndDetails d) {
              swipeInitial = 0;
              if (swipeDistance > 0) {
                setState(() {
                  if (selectedDay == 5) {
                    selectedDay = 7;
                  } else if (selectedDay == 7) {
                    selectedDay = 1;
                  } else {
                    selectedDay++;
                  }
                  _activeIndex = null;
                  Provider.of<Bloc>(context).scheduleLastSelection =
                      selectedDay;
                });
              } else {
                setState(() {
                  if (selectedDay == 1) {
                    selectedDay = 7;
                  } else if (selectedDay == 7) {
                    selectedDay = 5;
                  } else {
                    selectedDay--;
                  }
                  _activeIndex = null;
                  Provider.of<Bloc>(context).scheduleLastSelection =
                      selectedDay;
                });
              }
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              height: 60,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.purple[800]
                  : Colors.teal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  buildDayOfWeek("Sun", 7),
                  buildDayOfWeek("Mon", 1),
                  buildDayOfWeek("Tue", 2),
                  buildDayOfWeek("Wed", 3),
                  buildDayOfWeek("Thu", 4),
                  buildDayOfWeek("Fri", 5),
                  buildDayOfWeek("Sat", 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
// #endregion
  }
}
