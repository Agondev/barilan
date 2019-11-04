import 'dart:async';  
import 'package:bar_ilan/blocs/bloc.dart';
import 'package:bar_ilan/models/grade.dart';
import 'package:bar_ilan/utils/dio.dart';
import 'package:bar_ilan/utils/html2widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:html/parser.dart' as parser;
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:queries/collections.dart';

class GradesView extends StatefulWidget {
  @override
  _GradesViewState createState() => _GradesViewState();
}

class _GradesViewState extends State<GradesView> {
  Future<List<Grade>> gradesList;
  var _refreshController = RefreshController(initialRefresh: false);
  int _activeIndex;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance
        .addPostFrameCallback((_) => gradesList = getGradesList());
  }

  Future<List<Grade>> getGradesList({bool forceRefresh = false}) async {
    Response result =
        await ping(context, page: dioPageGrades, refresh: forceRefresh);
    if (result == null) {
      return null;
    }
    else if (result.data == DioEvent.NoUsernameOrPassword) {
      print('test');
      return null;
    }
    return Collection(Converter.gradeList(parser
            .parse(result.data.toString())
            .querySelector("#ContentPlaceHolder1_gvGradesList")
            .children[0]))
        .orderByDescending((t) => int.tryParse(t.grade))
        .thenBy((t) => !t.grade.toLowerCase().contains('f'))
        .toList();
    // Completer<List<Grade>> completer = Completer();
    // completer.complete(null);
    // return completer.future.then((onValue) => Collection(Converter.gradeList(
    //         parser
    //             .parse(ping(dom.grades).toString())
    //             .querySelector("#ContentPlaceHolder1_gvGradesList")
    //             .children[0]))
    //     .orderByDescending((t) => int.tryParse(t.grade))
    //     .thenBy((t) => !t.grade.toLowerCase().contains('f'))
    //     .toList());
  }

  void _onRefresh() async {
    // await getGradesList(force: true)
    setState(() {
      _refreshController.refreshFailed();
    });
    // _refreshController.refreshCompleted();
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

    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<Grade>>(
              future: gradesList,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.done) {
                  // print(snap.data);
                  if (snap.data == null) {
                    return Center(
                      child: Text("Error"),
                    );
                  }
                  return SmartRefresher(
                    controller: _refreshController,
                    header: ClassicHeader(
                      completeDuration: Duration(milliseconds: 1500),
                    ),
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: ListView.builder(
                      itemCount: snap.data.length,
                      itemBuilder: (context, idx) {
                        return Container(
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              cardColor: snap.data[idx].grade
                                      .toLowerCase()
                                      .contains("f")
                                  ? Colors.red[800]
                                  : ((int.tryParse((snap.data[idx].grade)) ??
                                              0) >
                                          (snap.data[idx].minimum ?? 0)
                                      ? Colors.green[800]
                                      : Colors.grey[800]),
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
                                  headerBuilder: (context, isExpanded) =>
                                      Container(
                                    child: ListTile(
                                      title: Text(
                                        snap.data[idx].courseName,
                                      ),
                                      trailing: Text(snap.data[idx].grade != ""
                                          ? snap.data[idx].grade
                                          : "TBD"),
                                    ),
                                  ),
                                  body: Column(
                                    children: [
                                      buildTile(
                                          "Minimum",
                                          snap.data[idx].minimum != null
                                              ? snap.data[idx].minimum
                                                  .toString()
                                              : "Unknown"),
                                      buildTile(
                                          "Teacher", snap.data[idx].teacher),
                                      buildTile(
                                          "Code", snap.data[idx].courseCode),
                                      buildTile(
                                          "Last Update",
                                          snap.data[idx].lastUpdate != ""
                                              ? snap.data[idx].lastUpdate
                                              : "None"),
                                      buildTile(
                                          "Period", snap.data[idx].period),
                                      buildTile(
                                          "Remark",
                                          (snap.data[idx].remark == "")
                                              ? "None"
                                              : snap.data[idx].remark),
                                      buildTile(
                                        "Points",
                                        snap.data[idx].points.toString(),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (snap.hasError) {
                  return Center(
                    child: Text("Error."),
                  );
                } else if (snap.connectionState == ConnectionState.waiting || snap.connectionState == ConnectionState.active) {
                  return RefreshProgressIndicator();
                }
                return Center(child: Text(Provider.of<Bloc>(context).error ?? "Unknown Error"),);
              },
            ),
          ),
        ],
      ),
    );
  }
}
