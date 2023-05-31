import 'package:flutter/material.dart';
import 'package:pocket_timetable/constants/page_titles.dart';
import 'package:pocket_timetable/models/userdata.dart';

import '../utils.dart';

class SetGroupPage extends StatefulWidget {
  final Userdata? userdata;

  const SetGroupPage({Key? key, this.userdata}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SetGroupPageState();
  }
}

class _SetGroupPageState extends State<SetGroupPage> {

  void _returnToUserdataPage(BuildContext context) {
    goBack(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(
          PageTitles.userdataSetupTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 20
          ),
        ),
        leading: BackButton(
          color: Theme.of(context).colorScheme.secondary,
          onPressed: () => _returnToUserdataPage(context),
        ),
      ),
      body: Container(
        //TODO: Сделать а-ля SearchBar для выбора учебной группы
        color: Colors.red,
      ),
    );
  }

}