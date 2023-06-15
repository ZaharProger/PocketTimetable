import 'package:flutter/material.dart';
import 'package:pocket_timetable/components/subject_card.dart';
import 'package:pocket_timetable/constants/labels.dart';
import 'package:pocket_timetable/constants/prefs_keys.dart';
import 'package:pocket_timetable/constants/routes.dart';
import 'package:pocket_timetable/models/subject.dart';
import 'package:pocket_timetable/timetable_extension.dart';
import 'package:pocket_timetable/models/userdata.dart';
import 'package:pocket_timetable/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;

import '../constants/api.dart';
import '../models/study_day.dart';

class TodayTimetablePage extends StatefulWidget {
  const TodayTimetablePage({Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TodayTimetablePageState();
  }
}

class _TodayTimetablePageState extends State<TodayTimetablePage> {
  String _greetingText = "";
  LinearGradient _pageBackgroundColor = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment(0.8, 1),
      colors: [
        Color.fromARGB(255, 55, 106, 117),
        Color.fromARGB(255, 42, 70, 76)
      ]
  );
  List<Subject> _todaySubjects = [];
  late PageController _pageController;
  int _activePage = 1;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.9, initialPage: 1);

    _getUserdata().then((userdata) {
      var (greeting, backgroundColor) = _getPageSettings(
          userdata.userName ?? ''
      );
      setState(() {
        _greetingText = greeting;
        _pageBackgroundColor = backgroundColor;
      });

      isTimetableExists().then((hasTimetable) {
        if (!hasTimetable) {
          Map<String, String> headers = {
            Api.ngrokSkipWarningHeader: '10'
          };
          Map<String, dynamic> params = {
            Api.universityIdKey: (userdata.universityId ?? 0).toString(),
            Api.groupIdKey: (userdata.groupId ?? 0).toString()
          };

          getDataFromServer(
              Api.timetable, headers, params
          ).then((responseData) {
            _saveTimetable(
                responseData.map<StudyDay>((item) {
                  return StudyDay.fromResponse(item);
                }).toList());
          }
          ).then((_) => _getTodayTimetable().then((timetable) =>
            setState(() => _todaySubjects = timetable.subjects)
          ));
        }
        else {
          _getTodayTimetable().then((timetable) {
            setState(() {
              _todaySubjects = timetable.subjects;
            });
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<Userdata> _getUserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return Userdata.all(
      prefs.getString(PrefsKeys.userName),
      prefs.getInt(PrefsKeys.userUniversity),
      prefs.getInt(PrefsKeys.userGroup)
    );
  }

  Future<void> _saveTimetable(List<StudyDay> timetable) async {
    String timetableJson = convert.jsonEncode(timetable.toJsonString());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PrefsKeys.weekTimetable, timetableJson);
  }

  Future<StudyDay> _getTodayTimetable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String weekTimetable = prefs.getString(PrefsKeys.weekTimetable)!;

    StudyDay todayTimetable = StudyDay();
    List<StudyDay> timetableFromJson = [];

    timetableFromJson.addFromJson(convert.jsonDecode(weekTimetable));
    if (timetableFromJson.isNotEmpty) {
      RegExp dayRegex = RegExp(r"\d+");
      todayTimetable = timetableFromJson.firstWhere((studyDay) {
        String day = studyDay.day;
        return dayRegex.stringMatch(day)! == DateTime.now().day.toString();
      }, orElse: () => StudyDay());
    }

    return todayTimetable;
  }

  (String, LinearGradient) _getPageSettings(String username) {
    int currentHour = DateTime.now().hour;

    var (greeting, pageColors) = switch(currentHour) {
      >=5 && <=11 => ('Доброе утро', [
        const Color.fromARGB(255, 241, 218, 93),
        const Color.fromARGB(255, 255, 147, 47)
      ]),
      >=12 && <=16 => ('Добрый день', [
        const Color.fromARGB(255, 93, 241, 215),
        const Color.fromARGB(255, 43, 166, 255)
      ]),
      >=17 && <=23 => ('Добрый вечер', [
        const Color.fromARGB(255, 219, 133, 85),
        const Color.fromARGB(255, 13, 56, 165)
      ]),
      _ => ('Доброй ночи', [
        const Color.fromARGB(255, 44, 40, 96),
        const Color.fromARGB(255, 0, 0, 0)
      ])
    };

    LinearGradient pageBackground = LinearGradient(
      begin: Alignment.topLeft,
      end: const Alignment(0.8, 1),
      colors: pageColors
    );

    return ('$greeting, $username!', pageBackground);
  }

  void _weekTimetableButtonClickHandler() {
    clearHistory(context);
    redirect(context, Routes.weekTimetable);
  }

  @override
  Widget build(BuildContext context) {
    LinearGradient cardBackground = LinearGradient(
        begin: _pageBackgroundColor.begin,
        end: _pageBackgroundColor.end,
        colors: _pageBackgroundColor.colors.reversed.toList()
    );

    return Container(
      decoration: BoxDecoration(
        gradient: _pageBackgroundColor
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 5,
                top: 30,
                right: 5,
                bottom: 10
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                _greetingText,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 5
            ),
            child: Text(
              Labels.subjectsSliderHeader,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: PageView.builder(
              itemCount: _todaySubjects.length,
              pageSnapping: true,
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _activePage = page;
                });
              },
              itemBuilder: (context, index) {
                return SubjectCard(
                    subjectKey: 'subject_card_$index',
                    subject: _todaySubjects[index],
                    cardColor: cardBackground,
                    cardMargin: _activePage == index? 10 : 15
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(_todaySubjects.length, (index) {
              return Container(
                key: Key('slider_$index'),
                margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 3
                ),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: _activePage == index?
                    Colors.white : Colors.white30,
                    shape: BoxShape.circle
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.only(
                left: 5,
                top: 10,
                right: 5,
                bottom: 30
            ),
            child: Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () => _weekTimetableButtonClickHandler(),
                  child: Text(
                    Labels.weekTimetableLabel,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                        decoration: TextDecoration.none
                    ),
                  )
                )
            ),
          )
        ],
      ),
    );
  }
}
