import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;

import 'constants/api.dart';
import 'constants/prefs_keys.dart';
import 'models/validation_case.dart';

void redirect(BuildContext context, String route, [Object? args]) {
  Navigator.of(context).pushNamed(route, arguments: args);
}

void clearHistory(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
}

void goBack(BuildContext context) {
  Navigator.of(context).pop();
}

String? validate(String value, ValidationCase validationCase) {
  return validationCase.regExp.hasMatch(value)?
    null : validationCase.messageIfError;
}

String getTimeFromSeconds(int time) {
  int hours = time ~/ 3600;
  int minutes = (time - hours * 3600) ~/ 60;
  String hoursString = hours < 10? '0$hours' : hours.toString();
  String minutesString = minutes < 10? '0$minutes' : minutes.toString();

  return '$hoursString:$minutesString';
}

Future<dynamic> getDataFromServer(String endpoint,
    [Map<String, String>? headers, Map<String, dynamic>? params]) async {

  dynamic dataFromResponse = [];

  Uri url = Uri.https(Api.host, '${Api.apiRoot}$endpoint', params);
  http.Response response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    Map<String, dynamic> responseData = convert
        .jsonDecode(response.body) as Map<String, dynamic>;

    if (responseData[Api.successKey]) {
      dataFromResponse = responseData[Api.dataKey];
    }
  }

  return dataFromResponse;
}

Future<bool> isUserDataConfigured() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool hasUniversity = prefs.containsKey(PrefsKeys.userUniversity);
  bool hasGroup = prefs.containsKey(PrefsKeys.userGroup);
  bool hasName = prefs.containsKey(PrefsKeys.userName);

  return hasUniversity && hasGroup && hasName;
}

Future<bool> isTimetableExists() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.containsKey(PrefsKeys.weekTimetable);
}