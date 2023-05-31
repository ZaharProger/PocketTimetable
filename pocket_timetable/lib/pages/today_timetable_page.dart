import 'package:flutter/material.dart';

import '../utils.dart';

class TodayTimetablePage extends StatefulWidget {
  const TodayTimetablePage({Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TodayTimetablePageState();
  }
}

class _TodayTimetablePageState extends State<TodayTimetablePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          defineGreeting('user'),
          textAlign: TextAlign.left,
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
