import 'package:pocket_timetable/models/identity_model.dart';

import '../constants/api.dart';

class Group extends IdentityModel {
  int? universityId;

  Group.fromResponse(Map<String, dynamic> dataFromResponse) {
    id = dataFromResponse[Api.idKey] as int;
    name = dataFromResponse[Api.nameKey] as String;
    universityId = dataFromResponse[Api.universityIdKey] as int;
  }
}