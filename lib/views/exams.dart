import 'package:bar_ilan/models/exam.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:queries/collections.dart';

class ExamsView extends StatefulWidget {
  final List<Exam> examList;

  ExamsView(this.examList);

  @override
  _ExamsViewState createState() => _ExamsViewState();
}

class _ExamsViewState extends State<ExamsView> {
  var _refreshController = RefreshController(initialRefresh: false);
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
    Widget buildTile(String title, String trailing) {
      return Container(
        color: Theme.of(context).canvasColor,
        padding: EdgeInsets.symmetric(horizontal: 20),
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
                    : Colors.black),
          ),
          dense: true,
        ),
      );
    }

    var filteredList = Collection(widget.examList)
        .orderBy((t) => t.date.year)
        .thenBy((t) => t.date.month)
        .thenBy((t) => t.date.day)
        .toList();
    // print(filteredList.length);
    // filteredList.forEach((f)=>print(f.courseName));

    /** 
     * ! Add to calendar
    */

    return Container(
      child: SmartRefresher(
        header: ClassicHeader(
          idleText: "Last updated " +
              DateTime.now()
                  .difference(
                      DateTime.now().subtract(Duration(days: 4, hours: 9)))
                  .inHours
                  .toString() +
              " hours ago",
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (context, i) {
            return Container(
              child: Theme(
                data: Theme.of(context).copyWith(
                    cardColor: (filteredList[i].dueTerm.contains(RegExp('1|א'))
                        ? Colors.blue[800]
                        : (filteredList[i].dueTerm.contains(RegExp("2|ב")))
                            ? Colors.deepPurple[800]
                            : Colors.brown[800]),
                    textTheme: TextTheme(body1: TextStyle(color: Colors.white)),
                    disabledColor: Colors.white),
                child: ExpansionPanelList(
                  expansionCallback: (c, idx) => setState(() {
                    _activeIndex = _activeIndex == i ? null : i;
                  }),
                  children: [
                    ExpansionPanel(
                      isExpanded: _activeIndex == i,
                      canTapOnHeader: true,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          title: Text(filteredList[i].courseName),
                          subtitle: Text(filteredList[i].dueTerm),
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text((filteredList[i].date.day < 11 ? "0" : "") +
                                  filteredList[i].date.day.toString() +
                                  "." +
                                  (filteredList[i].date.month < 11 ? "0" : "") +
                                  filteredList[i].date.month.toString() +
                                  "." +
                                  filteredList[i]
                                      .date
                                      .year
                                      .toString()
                                      .substring(2)),
                              Icon(
                                Icons.access_time,
                                color: Colors.white,
                              ),
                              Expanded(
                                child: Text(
                                  filteredList[i].time.format(context),
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            children: <Widget>[
                              Text((filteredList[i].building != 0)
                                  ? filteredList[i].building
                                  : "TBD"),
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              Text((filteredList[i].building != 0)
                                  ? filteredList[i].room
                                  : "TBD"),
                            ],
                          ),
                        );
                      },
                      body: Column(
                        children: <Widget>[
                          buildTile("Code", filteredList[i].courseCode),
                          buildTile("Teacher", filteredList[i].teacher),
                          buildTile("Period", filteredList[i].period),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
