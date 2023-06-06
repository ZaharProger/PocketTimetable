import 'package:pocket_timetable/constants/api.dart';
import 'package:pocket_timetable/models/identity_model.dart';

class University extends IdentityModel {
  String shortName = '';

  University(int id, String name, this.shortName) {
    this.id = id;
    this.name = name;
  }

  University.fromResponse(Map<String, dynamic> dataFromResponse) {
    id = dataFromResponse[Api.idKey] as int;
    name = dataFromResponse[Api.nameKey] as String;
    shortName = dataFromResponse[Api.shortNameKey] as String;
  }
}