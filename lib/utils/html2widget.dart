import 'package:bar_ilan/models/schedule.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:html/dom.dart';
import 'package:quartet/quartet.dart';
import 'package:bar_ilan/models/grade.dart';

class Converter {
  static List<Grade> gradeList(Element res) {
    var gradeList = List<Grade>();
    res.children.removeAt(0);
    res.children.forEach((f)=>f.children[9].children.removeAt(0));
    res.children.forEach((f) => gradeList.add(Grade(
      courseCode: f.children[0].text,
      courseName: f.children[1].text,
      teacher: titleCase(f.children[2].text),
      period: f.children[3].text,
      points: int.tryParse(f.children[4].text),
      minimum: int.tryParse(f.children[5].text),
      grade: f.children[6].text.trim(),
      intGrade: (f.children[6].text.trim().length > 0) ? int.tryParse(RegExp(r"(\d+)", multiLine: true, caseSensitive: false,)?.firstMatch(f.children[6].text.trim())?.group(0) ?? "0") : null,
      lastUpdate: f.children[7].text.trim(),
      remark: f.children[8].text.trim(),
      // assignments: List<Assignment>()..add(Assignment(weight: f.children[1].children[0].children[0].children[1].children[2].text))
      // assignments: f.children[9].children[1].firstChild.firstChild.children.map((a)=>Assignment(weight: a.children[0].text, grade: int.tryParse(a.children[1].text))).toList()
    )));
    return gradeList;
  }

  static List<Schedule> scheduleList(Element res) {
    var scheduleList = List<Schedule>();
    res.children.removeAt(0);
    res.children.forEach(
      (f) => scheduleList.add(
        Schedule(
          dayOfWeek: day2int(f?.children[0]?.text),
          startTime: prefix0.TimeOfDay(
            hour: int.tryParse(
                f?.children[1]?.text?.split("-")[0]?.split(":")[0]),
            minute: int.tryParse(
                f?.children[1]?.text?.split("-")[0]?.split(":")[1]),
          ),
          endTime: prefix0.TimeOfDay(
            hour: int.tryParse(
                f?.children[1]?.text?.split("-")[1]?.split(":")[0]),
            minute: int.tryParse(
                f?.children[1]?.text?.split("-")[1]?.split(":")[1]),
          ),
          courseCode: f?.children[2]?.text,
          courseName: f?.children[3]?.text,
          meetingType: f?.children[4]?.text,
          period: f?.children[5]?.text,
          teacher: titleCase(f?.children[6]?.text),
          yearlyHours: int.parse(f?.children[7]?.text),
          points: int.tryParse(f?.children[8]?.text),
          building: int.tryParse(f?.children[9]?.text?.split("-")[0]?.trim()),
          room: int.tryParse(f?.children[9]?.text?.split("-")[1]?.trim()),
          status: f?.children[10]?.text,
          link: (f?.children[11].children.length > 0)
              ? f?.children[11].children[0].attributes["href"]
              : null,
        ),
      ),
    );
    return scheduleList;
  }

  static int day2int(String string) {
    switch (string.toLowerCase()) {
      case "sun":
        return 7;
        break;
      case "mon":
        return 1;
        break;
      case "tue":
        return 2;
        break;
      case "wed":
        return 3;
        break;
      case "thu":
        return 4;
        break;
      case "fri":
        return 5;
        break;
      default:
        return null;
    }
  }
}
