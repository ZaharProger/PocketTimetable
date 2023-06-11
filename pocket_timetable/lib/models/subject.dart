import 'package:pocket_timetable/constants/api.dart';
import 'package:pocket_timetable/models/base_model.dart';

class Subject extends BaseModel {
  String tutor = '';
  String subjectType = '';
  String classroom = '';
  int timeStart = 0;
  int timeEnd = 0;
  String subGroupName = '';

  Subject.fromResponse(Map<String, dynamic> dataFromResponse) {
    name = dataFromResponse[Api.nameKey] as String;
    tutor = dataFromResponse[Api.tutorKey] as String;
    subjectType = dataFromResponse[Api.subjectTypeKey] as String;
    classroom = dataFromResponse[Api.classroomKey] as String;
    timeStart = dataFromResponse[Api.timeStartKey] as int;
    timeEnd = dataFromResponse[Api.timeEndKey] as int;
    subGroupName = dataFromResponse[Api.subGroupName] as String;
  }
}