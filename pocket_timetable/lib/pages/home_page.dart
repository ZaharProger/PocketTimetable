import 'package:flutter/material.dart';
import 'package:pocket_timetable/constants/prefs_keys.dart';
import 'package:pocket_timetable/pages/today_timetable_page.dart';
import 'package:pocket_timetable/pages/set_primary_userdata_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/page_titles.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  bool _isConfigured = false;
  String _appBarTitle = '';

  @override
  void initState() {
    super.initState();

    _isUserDataConfigured().then((cfgState) {
      setState(() {
        _isConfigured = cfgState;
        _appBarTitle = cfgState? '' : PageTitles.userdataSetupTitle;
      });
    });
  }

  Future<bool> _isUserDataConfigured() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool hasUniversity = prefs.containsKey(PrefsKeys.userUniversity);
    bool hasGroup = prefs.containsKey(PrefsKeys.userGroup);
    bool hasName = prefs.containsKey(PrefsKeys.userName);

    return hasUniversity && hasGroup && hasName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        title: Text(
          _appBarTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge,
        )
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: _isConfigured?
          const TodayTimetablePage() :
          const SingleChildScrollView(
            child: SetPrimaryUserdataPage(),
          ),
      )
    );
  }
}