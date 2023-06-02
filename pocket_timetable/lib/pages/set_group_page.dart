import 'package:flutter/material.dart';
import 'package:pocket_timetable/constants/api.dart';
import 'package:pocket_timetable/constants/page_titles.dart';
import 'package:pocket_timetable/constants/prefs_keys.dart';
import 'package:pocket_timetable/models/userdata.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;

import '../constants/labels.dart';
import '../models/group.dart';
import '../utils.dart';

class SetGroupPage extends StatefulWidget {
  final Userdata userdata;

  const SetGroupPage({Key? key, required this.userdata}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SetGroupPageState();
  }
}

class _SetGroupPageState extends State<SetGroupPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Group> _groups = [];
  List<Group> _searchResults = [];

  @override
  void initState() {
    super.initState();

    int universityId = widget.userdata.universityId ?? 0;
    _getGroupsByUniversityId(universityId).then((groups) {
      setState(() {
        _groups = groups;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Future<List<Group>> _getGroupsByUniversityId(int universityId) async {
    List<Group> groupsFromResponse = [];

    Uri url = Uri.https(
        Api.host,
        '${Api.apiRoot}${Api.groups}',
        { Api.universityIdKey: universityId.toString() }
    );

    http.Response response = await http.get(url, headers: {
      Api.ngrokSkipWarningHeader: '10'
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = convert
          .jsonDecode(response.body) as Map<String, dynamic>;
      groupsFromResponse = responseData[Api.successKey]?
          responseData[Api.dataKey].map<Group>((groupFromResponse) {
            return Group.fromResponse(groupFromResponse);
          }).toList()
          :
          [];
    }

    return groupsFromResponse;
  }

  void _returnToUserdataPage(BuildContext context) {
    goBack(context);
  }

  void _searchGroups(String searchString) {
    setState(() {
      _searchResults = _groups.where((group) {
        return group.name.toLowerCase().contains(searchString.toLowerCase());
      }).toList();
    });
  }

  Future<bool> _saveUserdata(Userdata userdata) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool result = false;
    if (userdata.userName != null && userdata.universityId != null &&
        userdata.groupId != null) {

      prefs.setString(PrefsKeys.userName, userdata.userName!);
      prefs.setInt(PrefsKeys.userUniversity, userdata.universityId!);
      prefs.setInt(PrefsKeys.userGroup, userdata.groupId!);

      result = true;
    }

    return result;
  }

  void _onGroupTapHandler(int selectedGroupIndex) {
    widget.userdata.groupId = _searchResults[selectedGroupIndex].id;
    _saveUserdata(widget.userdata).then((result) {
      if (result) {
        clearHistory(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(
          PageTitles.userdataSetupTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        leading: BackButton(
          color: Theme.of(context).colorScheme.secondary,
          onPressed: () => _returnToUserdataPage(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (searchString) {
                if (searchString.length >= 2) {
                  _searchGroups(searchString);
                }
                else {
                  setState(() {
                    _searchResults = [];
                  });
                }
              },
              autofocus: false,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary,
                          width: 2.0,
                          style: BorderStyle.solid
                      )
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onPrimary,
                          width: 2.0,
                          style: BorderStyle.solid
                      )
                  ),
                  hintText: Labels.userGroupLabel,
                  hintStyle: Theme.of(context).textTheme.labelMedium,
                  prefixIcon: const Icon(Icons.search),
                  prefixIconColor: Theme.of(context).colorScheme.secondary,
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.all(5.0)
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _searchResults.length,
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Color.fromARGB(80, 255, 255, 255),
                  thickness: 2,
                  endIndent: 2,
                );
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _onGroupTapHandler(index);
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.only(
                        left: 5,
                        top: 8,
                        right: 5,
                        bottom: 5
                    ),
                    child: Text(
                      _searchResults[index].name,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              },
              padding: const EdgeInsets.all(5.0),
            ),
          )
        ],
      ),
    );
  }

}