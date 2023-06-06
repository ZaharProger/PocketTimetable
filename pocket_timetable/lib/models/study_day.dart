import 'package:pocket_timetable/models/base_model.dart';
import 'package:pocket_timetable/models/subject.dart';

import '../constants/api.dart';

class StudyDay extends BaseModel {
  late String day;
  late List<Subject> subjects;

  StudyDay() {
    day = '';
    subjects = [];
  }

  StudyDay.fromResponse(Map<String, dynamic> dataFromResponse) {
    name = dataFromResponse[Api.nameKey] as String;
    day = dataFromResponse[Api.dayKey] as String;
    subjects = dataFromResponse[Api.subjectsKey].map<Subject>((subject) {
      return Subject.fromResponse(subject);
    }).toList();
  }
}