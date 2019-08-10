import 'package:flutter/material.dart';

class Exam {
  DateTime date;
  int dayOfWeek;
  TimeOfDay time;
  int grade;
  int finalGrade;
  int building;
  int room;
  String period;
  String courseCode;
  String courseName;
  String teacher;
  String register;
  String examNotebook;
  String gradeAppeal;
  String notebookNumber;
  bool isFinal;

  Exam({
    this.building,
    this.courseCode,
    this.courseName,
    this.date,
    this.dayOfWeek,
    this.examNotebook,
    this.grade,
    this.finalGrade,
    this.gradeAppeal,
    this.isFinal,
    this.notebookNumber,
    this.period,
    this.register,
    this.room,
    this.teacher,
    this.time,
  });
}