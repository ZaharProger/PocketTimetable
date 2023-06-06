import 'package:pocket_timetable/models/study_day.dart';

import 'constants/api.dart';

extension TimetableExtension on List<StudyDay> {

  Map<String, dynamic> toJsonString() {
    Map<String, dynamic> json = {};
    json[Api.dataKey] = map((studyDay) =>
    {
      Api.nameKey: studyDay.name,
      Api.dayKey: studyDay.day,
      Api.subjectsKey: studyDay.subjects.map((subject) =>
      {
        Api.nameKey: subject.name,
        Api.tutorKey: subject.tutor,
        Api.subjectTypeKey: subject.subjectType.index,
        Api.classroomKey: subject.classroom,
        Api.timeStartKey: subject.timeStart,
        Api.timeEndKey: subject.timeEnd,
        Api.subGroupName: subject.subGroupName
      }
      ).toList()
    }
    ).toList();

    return json;
  }

  void addFromJson(Map<String, dynamic> json) {
    List<StudyDay> timetableFromJson = json[Api.dataKey].map<StudyDay>((item) {
      return StudyDay.fromResponse(item);
    }).toList();
    addAll(timetableFromJson);
  }
}