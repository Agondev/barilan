import 'package:bar_ilan/models/grade.dart';
import 'package:bar_ilan/utils/html2widget.dart';
import 'package:flutter/material.dart';
import 'package:bar_ilan/html.dart' as dom;
import 'package:flutter/scheduler.dart';
import 'package:html/parser.dart' as parser;

class GradesView extends StatefulWidget {
  @override
  _GradesViewState createState() => _GradesViewState();
}

class _GradesViewState extends State<GradesView> {
  var _scrollController = ScrollController();
  List<Grade> gradesList;

  @override
  void initState() {
    super.initState();

    gradesList = Converter.gradeList(parser
        .parse(dom.grades)
        .querySelector("#ContentPlaceHolder1_gvGradesList")
        .children[0])
      ..sort((a, b) => (a?.intGrade?.compareTo(b?.intGrade ?? -1)) ?? -1);

    SchedulerBinding.instance.addPostFrameCallback((_) =>
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            curve: Curves.linear, duration: Duration(microseconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        controller: _scrollController,
        reverse: true,
        children: gradesList
            .map((f) => Container(
                  color: f.grade.toLowerCase().contains("f")
                      ? Colors.red.withOpacity(.5)
                      : (((int.tryParse(f.grade) ?? 0) >
                              (f?.minimum ?? (int.tryParse(f.grade) ?? 0)))
                          ? Colors.green.withOpacity(.5)
                          : Theme.of(context).disabledColor),
                  child: InkWell(
                    onTap: () => showDialog(context: context, builder: (context) {
                      return SimpleDialog(
                        title: Column(
                          children: <Widget>[
                            Text(f.courseName),
                            Text(f.teacher, textScaleFactor: .75,)
                          ],
                        ),
                        children: <Widget>[
                          ListTile(
                            title: Text("Code"),
                            trailing: Text(f.courseCode),
                          ),
                          ListTile(
                            title: Text("Last update"),
                            trailing: Text((f.lastUpdate == "") ? "None" : f.lastUpdate),
                          ),
                          ListTile(
                            title: Text("Minimum"),
                            trailing: Text(f.minimum.toString()),
                          ),
                          ListTile(
                            title: Text("Period"),
                            trailing: Text(f.period),
                          ),
                          ListTile(
                            title: Text("Remarks"),
                            trailing: Text((f.remark == "") ? "None" : f.remark),
                          ),
                          ListTile(
                            title: Text("Points"),
                            trailing: Text(f.points.toString()),
                          ),
                          ListTile(
                            title: Text("Grade"),
                            trailing: Text((f.grade == "") ? "None" : f.grade),
                          )
                        ],
                      );
                    }),
                    child: ListTile(
                      title: Text(f.courseName),
                      subtitle: Text(f.teacher),
                      trailing: Text(f.grade),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
