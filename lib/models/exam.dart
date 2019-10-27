import 'package:flutter/material.dart';

class Exam {
  DateTime date;
  int dayOfWeek;
  TimeOfDay time;
  String dueTerm;
  String grade;
  String finalGrade;
  int building;
  int room;
  String period;
  String courseCode;
  String courseName;
  String teacher;
  String register;
  String notebook;
  String appeal;
  String notebookNumber;
  bool isFinal;

  Exam({
    this.building,
    this.courseCode,
    this.courseName,
    this.date,
    this.dueTerm,
    this.dayOfWeek,
    this.notebook,
    this.grade,
    this.finalGrade,
    this.appeal,
    this.isFinal,
    this.notebookNumber,
    this.period,
    this.register,
    this.room,
    this.teacher,
    this.time,
  });
}