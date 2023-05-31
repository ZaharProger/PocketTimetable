import 'package:flutter/material.dart';

import 'models/validation_case.dart';

void redirect(BuildContext context, String route, [Object? args]) {
  Navigator.of(context).pushNamed(route, arguments: args);
}

void goBack(BuildContext context) {
  Navigator.of(context).pop();
}

String defineGreeting(String username) {
  String greeting;
  int currentHour = DateTime.now().hour;

  if (currentHour >= 5 && currentHour <= 11) {
    greeting = 'Доброе утро';
  }
  else if (currentHour >= 12 && currentHour <= 16) {
    greeting = 'Добрый день';
  }
  else if (currentHour >= 17 && currentHour <= 23) {
    greeting = 'Добрый вечер';
  }
  else {
    greeting = 'Доброй ночи';
  }

  return '$greeting, $username!';
}

String? validate(String value, ValidationCase validationCase) {
  return validationCase.regExp.hasMatch(value)?
    null : validationCase.messageIfError;
}