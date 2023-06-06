import 'package:flutter/material.dart';
import 'package:pocket_timetable/constants/prefs_keys.dart';
import 'package:pocket_timetable/pages/today_timetable_page.dart';
import 'package:pocket_timetable/pages/set_primary_userdata_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/labels.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  bool? _isConfigured;

  @override
  void initState() {
    super.initState();

    _isUserDataConfigured().then((cfgState) {
      setState(() {
        _isConfigured = cfgState;
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

  Widget _getProgressBar() {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 5
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 20),
              Text(
                Labels.loadingLabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            ],
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isConfigured == null ?
      _getProgressBar() : _isConfigured! ?
      const TodayTimetablePage() : const SetPrimaryUserdataPage();
  }
}