import 'package:pocket_timetable/models/validation_case.dart';

class ValidationCases {
  static final ValidationCase notEmptyField = ValidationCase(
    RegExp(r"\S+"),
    'Поле должно быть заполнено'
  );
}