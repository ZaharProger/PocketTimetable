import 'package:flutter/material.dart';
import 'package:pocket_timetable/constants/labels.dart';
import 'package:pocket_timetable/constants/prefs_keys.dart';
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
  LinearGradient? _subjectCardBackgroundColor;
  List<Subject> _todaySubjects = [];
  late PageController _pageController;
  int _activePage = 1;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.9, initialPage: 1);

    _getUserdata().then((userdata) {
      var (greeting, backgroundColor, cardColor) = _getPageSettings(
          userdata.userName ?? ''
      );
      setState(() {
        _greetingText = greeting;
        _pageBackgroundColor = backgroundColor;
        _subjectCardBackgroundColor = cardColor;
      });

      _isTimetableExists().then((hasTimetable) {
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

  Future<bool> _isTimetableExists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(PrefsKeys.weekTimetable);
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

  (String, LinearGradient, LinearGradient) _getPageSettings(String username) {
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
    LinearGradient cardBackground = LinearGradient(
      begin: pageBackground.begin,
      end: pageBackground.end,
      colors: pageColors.reversed.toList()
    );

    return ('$greeting, $username!', pageBackground, cardBackground);
  }

  bool _isSubjectActive(Subject subject) {
    DateTime currentDateTime = DateTime.now();
    int currentSeconds = currentDateTime.hour * 3600 +
        currentDateTime.minute * 60;

    return currentSeconds >= subject.timeStart &&
        currentSeconds <= subject.timeEnd;
  }

  Widget _getSubjectCard(int index) {
    Subject subject = _todaySubjects[index];

    String subjectTimeStart = getTimeFromSeconds(subject.timeStart);
    String subjectTimeEnd = getTimeFromSeconds(subject.timeEnd);
    bool isActive = _isSubjectActive(subject);

    return Padding(
      key: Key("subject_card_$index"),
      padding: const EdgeInsets.only(
        bottom: 10
      ),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
          margin: EdgeInsets.all(_activePage == index? 10 : 15),
          decoration: BoxDecoration(
              gradient: _subjectCardBackgroundColor,
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(
                  Radius.circular(20)
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  offset: Offset(0, 5),
                  blurRadius: 10,
                )
              ]
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      subject.name,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '$subjectTimeStart-$subjectTimeEnd',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(
                            vertical: 1,
                            horizontal: 10
                        ),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                            color: isActive? Theme.of(context)
                                .colorScheme.onPrimaryContainer :
                            Colors.transparent,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20)
                            )
                        ),
                        child: Text(
                          isActive? Labels.subjectIsActiveLabel : '',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              subject.tutor,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              subject.classroom,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
              ),
            ],
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                return _getSubjectCard(index);
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
            ),
          )
        ],
      ),
    );
  }
}
