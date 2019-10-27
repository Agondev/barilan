import 'package:bar_ilan/models/exam.dart';
import 'package:bar_ilan/models/schedule.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:html/dom.dart';
import 'package:quartet/quartet.dart';
import 'package:bar_ilan/models/grade.dart';

class Converter {
  static List<Grade> gradeList(Element res) {
    var gradeList = List<Grade>();
    res.children.removeAt(0);
    res.children.forEach(
      (f) => gradeList.add(
        Grade(
          courseCode: f?.children[0]?.text,
          courseName: f?.children[1]?.text,
          teacher: titleCase(f.children[2]?.text),
          period: f?.children[3]?.text,
          points: f?.children[4]?.text,
          minimum: int.tryParse(f?.children[5]?.text?.trim()),
          grade: f?.children[6]?.text?.trim(),
          lastUpdate: f?.children[7]?.text?.trim(),
          remark: f?.children[8]?.text?.trim(),
        ),
      ),
    );
    return gradeList;
  }

  static List<Exam> examList(Element res) {
    var examList = List<Exam>();
    res.children.removeAt(0);
    res.children.forEach((f) {
      var exam = Exam();
      exam.date = DateTime(
          int.tryParse(f?.children[0]?.text?.split("/")[2]),
          int.tryParse(f?.children[0]?.text?.split("/")[1]),
          int.tryParse(f?.children[0]?.text?.split("/")[0]));
      exam.dayOfWeek = day2int(f?.children[1]?.text);
      exam.time = prefix0.TimeOfDay(
        hour: int.tryParse(f?.children[2]?.text?.split(":")[0]),
        minute: int.tryParse(f?.children[2]?.text?.split(":")[1]),
      );
      exam.dueTerm = f?.children[3]?.text;
      exam.grade = f?.children[4]?.text;
      exam.finalGrade = f?.children[5]?.text;
      if (f?.children[6]?.text?.trim() != "") {
        exam.building = int.tryParse(RegExp(r'(\d+)')
            .allMatches(f?.children[6]?.text)
            .map((m) => m.group(0))
            .first);
        exam.room = int.tryParse(RegExp(r'(\d+)')
            .allMatches(f?.children[6]?.text)
            .map((m) => m.group(0))
            .last);
      } else {
        exam.building = exam.room = 0;
      }
      exam.period = f?.children[7]?.text;
      exam.courseCode = f?.children[8]?.text;
      exam.courseName = f?.children[9]?.text?.trim();
      exam.teacher = titleCase(f?.children[10]?.text);
      exam.register = f?.children[11]?.text;
      exam.notebook = f?.children[12]?.text;
      exam.appeal = f?.children[13]?.text;
      exam.notebookNumber = f?.children[14]?.text;
      exam.isFinal =
          f?.children[15]?.attributes["checked"] == "checked" ? true : false;
      examList.add(exam);
    });
    return examList;
  }

  static List<Schedule> scheduleList(Element res) {
    var scheduleList = List<Schedule>();
    res.children.removeAt(0);
    // print(res.children);
    res.children.forEach(
      (f) {
        var schedule = Schedule();
        if (f?.children[0]?.text?.trim() != "") {
          schedule.dayOfWeek = day2int(f?.children[0]?.text);
        } else {
          schedule.dayOfWeek = day2int("0");
        }
        if (f?.children[1]?.text?.trim() != "") {
          schedule.startTime = prefix0.TimeOfDay(
            hour: int.tryParse(
                f?.children[1]?.text?.split("-")[0]?.split(":")[0]),
            minute: int.tryParse(
                f?.children[1]?.text?.split("-")[0]?.split(":")[1]),
          );
          schedule.endTime = prefix0.TimeOfDay(
            hour: int.tryParse(
                f?.children[1]?.text?.split("-")[1]?.split(":")[0]),
            minute: int.tryParse(
                f?.children[1]?.text?.split("-")[1]?.split(":")[1]),
          );
        } else {
          schedule.startTime = prefix0.TimeOfDay(
            hour: 0,
            minute: 0,
          );
          schedule.endTime = prefix0.TimeOfDay(
            hour: 0,
            minute: 0,
          );
        }
        schedule.courseCode = f?.children[2]?.text;
        schedule.courseName = f?.children[3]?.text;
        schedule.meetingType = f?.children[4]?.text;
        schedule.period = f?.children[5]?.text;
        schedule.teacher = titleCase(f?.children[6]?.text?.trim());
        if (f?.children[7]?.text?.trim() != "") {
          schedule.yearlyHours = int.parse(f?.children[7]?.text);
        } else {
          schedule.yearlyHours = 0;
        }
        if (f?.children[8]?.text?.trim() != "") {
          schedule.points = int.tryParse(f?.children[8]?.text);
        } else {
          schedule.points = 0;
        }
        if (f?.children[9]?.text?.trim() != "") {
          schedule.building = int.tryParse(RegExp(r'(\d+)')
              .allMatches(f?.children[9]?.text)
              .map((m) => m.group(0))
              .first);
          schedule.room = int.tryParse(RegExp(r'(\d+)')
              .allMatches(f?.children[9]?.text)
              .map((m) => m.group(0))
              .last);
        } else {
          schedule.building = null;
          schedule.room = null;
        }
        schedule.status = f?.children[10]?.text;
        schedule.link = (f?.children[11].children.length > 0)
            ? f?.children[11].children[0].attributes["href"]
            : null;
        scheduleList.add(schedule);
      },
    );
    return scheduleList;
  }

  static int day2int(String string) {
    switch (string.toLowerCase()) {
      case "א'":
      case "sun":
        return 7;
        break;
      case "ב'":
      case "mon":
        return 1;
        break;
      case "ג'":
      case "tue":
        return 2;
        break;
      case "ד'":
      case "wed":
        return 3;
        break;
      case "ה'":
      case "thu":
        return 4;
        break;
      case "ו'":
      case "fri":
        return 5;
        break;
      default:
        return null;
    }
  }
}
