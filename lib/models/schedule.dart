import 'package:flutter/material.dart';

class Schedule {
  String courseCode;
  String courseName;
  String meetingType;
  String period;
  String teacher;
  String status;
  String link;
  int dayOfWeek;
  int yearlyHours;
  int points;
  int building;
  int room;
  TimeOfDay startTime;
  TimeOfDay endTime;

  Schedule({
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.courseCode,
    this.courseName,
    this.meetingType,
    this.period,
    this.teacher,
    this.yearlyHours,
    this.points,
    this.building,
    this.room,
    this.status,
    this.link,
  });
}
