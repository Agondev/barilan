import 'package:flutter/material.dart';

// successStyle(bool isDark, )

Color meetingType2Color(String type) {
  if (type == "Lecture") {
    return Colors.deepOrange[800];
  }
  return Colors.pink[800];
}

Color building2color(int building) {
  if (building < 200) {
    return Colors.purple[800];
  }
  else if (building < 300) {
    return Colors.yellow[800];
  }
  else if (building < 400) {
    return Colors.blue[800];
  }
  else if (building < 500) {
    return Colors.indigo[800];
  }
  else if (building < 600) {
    return Colors.lightBlue[800];
  }
  else if (building < 700) {
    return Colors.deepPurple[800];
  }
  else if (building < 800) {
    return Colors.amber[800];
  }
  else if (building < 900) {
    return Colors.red[800];
  }
  else if (building < 1000) {
    return Colors.green[800];
  }
  else if (building < 1100) {
    return Colors.indigo[800];
  }
  else if (building < 1200) {
    return Colors.lime[800];
  }
  return Colors.teal[800];
}