import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_timetable/constants/api.dart';
import 'package:pocket_timetable/constants/labels.dart';
import 'package:pocket_timetable/constants/routes.dart';
import 'package:pocket_timetable/constants/validation_cases.dart';
import 'package:pocket_timetable/models/university.dart';
import 'package:pocket_timetable/models/userdata.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../utils.dart';

class SetPrimaryUserdataPage extends StatefulWidget {
  const SetPrimaryUserdataPage({Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SetPrimaryUserdataPageState();
  }
}

class _SetPrimaryUserdataPageState extends State<SetPrimaryUserdataPage> {
  late TextEditingController _usernameController;

  University? _selectedUniversity;
  List<University> _universities = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController();

    _getUniversities().then((universities) {
      setState(() {
        _universities = universities;
        _selectedUniversity = universities.isEmpty?
          null : _universities.first;
      });
    });
  }

  Future<List<University>> _getUniversities() async {
    List<University> universitiesFromResponse = [];

    Uri url = Uri.https(Api.host, '${Api.apiRoot}${Api.getUniversities}');
    http.Response response = await http.get(url, headers: {
      Api.ngrokSkipWarningHeader: '10'
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = convert
          .jsonDecode(response.body) as Map<String, dynamic>;
      universitiesFromResponse = responseData[Api.successKey]?
          responseData[Api.dataKey].map<University>((universityFromResponse) {
            return University.fromResponse(universityFromResponse);
          }).toList()
          : [];
    }

    return universitiesFromResponse;
  }

  void _userdataFormHandler() {
    if (_formKey.currentState!.validate()) {
      redirect(
          context,
          Routes.setGroup,
          Userdata.withNameAndUniversity(
              _usernameController.text,
              _selectedUniversity!.id
          )
      );
    }
  }

  void _dropdownButtonOnChangedHandler(int value) {
    University newUniversity = _universities
        .firstWhere((university) => university.id == value);
    setState(() {
      _selectedUniversity = newUniversity;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: _universities.isEmpty?
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 20),
              Text(
                Labels.loadingLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 14
                ),
              )
            ],
          ) :
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  key: const Key('name_field'),
                  autofocus: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-Zа-яА-Я\s]+")
                    )
                  ],
                  validator: (value) => validate(
                      value ?? '',
                      ValidationCases.notEmptyField
                  ),
                  controller: _usernameController,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 14
                  ),
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10.0)
                          ),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary,
                              width: 2.0,
                              style: BorderStyle.solid
                          )
                      ),
                      errorBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10.0)
                          ),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onError,
                              width: 2.0,
                              style: BorderStyle.solid
                          )
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10.0)
                          ),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onError,
                              width: 2.0,
                              style: BorderStyle.solid
                          )
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10.0)
                          ),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onPrimary,
                              width: 2.0,
                              style: BorderStyle.solid
                          )
                      ),
                      labelText: Labels.userNameLabel,
                      labelStyle: const TextStyle(
                          color: Color.fromARGB(150, 255, 255, 255),
                          fontSize: 14.0
                      ),
                      floatingLabelAlignment: FloatingLabelAlignment.start,
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.all(5.0)
                  ),
                ),
                const SizedBox(height: 25),
                DropdownButtonFormField(
                  key: const Key('university_field'),
                  itemHeight: 60,
                  autofocus: false,
                  autovalidateMode: AutovalidateMode.disabled,
                  validator: (value) => validate(
                      '$value',
                      ValidationCases.notEmptyField
                  ),
                  isExpanded: true,
                  dropdownColor: Theme.of(context).colorScheme.primary,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary,
                              width: 2.0,
                              style: BorderStyle.solid
                          ),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10.0)
                          )
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onPrimary,
                              width: 2.0,
                              style: BorderStyle.solid
                          ),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10.0)
                          )
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10.0)
                          ),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onError,
                              width: 2.0,
                              style: BorderStyle.solid
                          )
                      ),
                      errorBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10.0)
                          ),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onError,
                              width: 2.0,
                              style: BorderStyle.solid
                          )
                      )
                  ),
                  value: _selectedUniversity?.id,
                  items: _universities.map((university) {
                    return DropdownMenuItem(
                      key: Key('university_${university.id}'),
                      value: university.id,
                      child: Text(
                        _selectedUniversity?.id == university.id?
                        university.shortName :
                        '${university.name} (${university.shortName})',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 14.0,
                            overflow: TextOverflow.visible
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (Object? value) {
                    int selectedUniversityId = value as int;
                    _dropdownButtonOnChangedHandler(selectedUniversityId);
                  },
                ),
                const SizedBox(height: 45),
                SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 45
                      ),
                      child: ElevatedButton(
                          key: const Key('continue_button'),
                          onPressed: () {
                            _userdataFormHandler();
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Theme.of(context)
                                  .colorScheme.secondary,
                              backgroundColor: Theme.of(context)
                                  .colorScheme.onPrimary,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10.0)
                                  )
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                  horizontal: 10.0
                              )
                          ),
                          child: Text(
                            Labels.continueButtonLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 16.0,
                                letterSpacing: 1,
                                overflow: TextOverflow.ellipsis
                            ),
                          )
                      ),
                    )
                )
              ],
            ),
          )
        )
    );
  }
}