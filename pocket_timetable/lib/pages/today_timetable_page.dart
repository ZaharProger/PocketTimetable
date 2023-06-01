import 'package:flutter/material.dart';
import 'package:pocket_timetable/constants/prefs_keys.dart';
import 'package:pocket_timetable/models/userdata.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';

class TodayTimetablePage extends StatefulWidget {
  const TodayTimetablePage({Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TodayTimetablePageState();
  }
}

class _TodayTimetablePageState extends State<TodayTimetablePage> {
  Userdata? _userdata;

  @override
  void initState() {
    super.initState();

    _getUserdata().then((userdata) {
      setState(() {
        _userdata = userdata;
      });
    });
  }

  Future<Userdata> _getUserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return Userdata.all(
      prefs.getString(PrefsKeys.userName),
      prefs.getInt(PrefsKeys.userUniversity),
      prefs.getInt(PrefsKeys.userGroup)
    );
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Сделать окно расписания на текущий день
    return Scaffold(
      appBar: AppBar(
        title: Text(
          defineGreeting(_userdata?.userName ?? ''),
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center
        ),
      ),
    );
  }
}
