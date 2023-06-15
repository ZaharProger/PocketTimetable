import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_timetable/components/subject_card.dart';
import 'package:pocket_timetable/timetable_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'dart:convert' as convert;

import '../constants/prefs_keys.dart';
import '../models/study_day.dart';
import '../utils.dart';

class WeekTimetablePage extends StatefulWidget {
  const WeekTimetablePage({Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WeekTimetablePageState();
  }
}

class _WeekTimetablePageState extends State<WeekTimetablePage> {
  List<StudyDay> _weekTimetable = [];

  @override
  void initState() {
    super.initState();

    _getWeekTimetable().then((weekTimetable) {
      setState(() {
        _weekTimetable = weekTimetable;
      });
    });
  }

  Future<bool> _removeUserdata() async {
    bool result = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isConfigured = await isUserDataConfigured();

    if (isConfigured) {
      await prefs.remove(PrefsKeys.userName);
      await prefs.remove(PrefsKeys.userUniversity);
      await prefs.remove(PrefsKeys.userGroup);

      result = true;
    }

    return result;
  }

  void _logoutHandler() {
    _removeUserdata().then((result) {
      if (result) {
        clearHistory(context);
      }
    });
  }

  Future<List<StudyDay>> _getWeekTimetable() async {
    List<StudyDay> weekTimetable = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(PrefsKeys.weekTimetable)) {
      String jsonTimetable = prefs.getString(PrefsKeys.weekTimetable)!;
      weekTimetable.addFromJson(convert.jsonDecode(jsonTimetable));
    }

    return weekTimetable;
  }

  @override
  Widget build(BuildContext context) {
    LinearGradient cardBackgroundColor = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment(0.8, 1),
        colors: [
          Color.fromARGB(255, 55, 106, 117),
          Color.fromARGB(255, 42, 70, 76)
        ]
    );

    return WillPopScope(
      onWillPop: () async {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return false;
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            title: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _weekTimetable.isNotEmpty? _weekTimetable.first.name : '',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => _logoutHandler(),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              )
            ],
          ),
          body: ListView.builder(
            itemCount: _weekTimetable.length,
            itemBuilder: (context, index) {
              return StickyHeader(
                header: Container(
                  height: 60,
                  color: const Color.fromARGB(240, 23, 39, 44),
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _weekTimetable[index].day,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                content: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: _weekTimetable[index].subjects.length,
                  itemBuilder: (context, i) {
                    return SizedBox(
                      height: 200,
                      child: SubjectCard(
                          subject: _weekTimetable[index].subjects[i],
                          subjectKey: 'subject_card_$i',
                          cardColor: cardBackgroundColor,
                          cardMargin: 20
                      ),
                    );
                  },
                ),
              );
            },
          )
      ),
    );
  }

}