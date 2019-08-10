class Grade {
  String courseCode;
  String courseName;
  String teacher;
  String period;
  int points;
  int minimum;
  int intGrade;
  String grade;
  String lastUpdate;
  String remark;
  List<Assignment> assignments;

  Grade({
    this.courseCode,
    this.courseName,
    this.teacher,
    this.period,
    this.points,
    this.minimum,
    this.grade,
    this.intGrade,
    this.lastUpdate,
    this.remark,
    this.assignments,
  });
}

class Assignment {
  String weight;
  int grade;

  Assignment({this.weight, this.grade});
}
