import 'package:pocket_timetable/constants/api.dart';
import 'package:pocket_timetable/constants/subject_types.dart';
import 'package:pocket_timetable/models/base_model.dart';

class Subject extends BaseModel {
  String tutor = '';
  SubjectTypes subjectType = SubjectTypes.values.first;
  String classroom = '';
  int timeStart = 0;
  int timeEnd = 0;
  String subGroupName = '';

  Subject.fromResponse(Map<String, dynamic> dataFromResponse) {
    name = dataFromResponse[Api.nameKey] as String;
    tutor = dataFromResponse[Api.tutorKey] as String;
    subjectType = SubjectTypes.values.elementAt(
        dataFromResponse[Api.subjectTypeKey] as int
    );
    classroom = dataFromResponse[Api.classroomKey] as String;
    timeStart = dataFromResponse[Api.timeStartKey] as int;
    timeEnd = dataFromResponse[Api.timeEndKey] as int;
    subGroupName = dataFromResponse[Api.subGroupName] as String;
  }
}