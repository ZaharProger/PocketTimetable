import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_timetable/constants/api.dart';
import 'package:pocket_timetable/constants/labels.dart';
import 'package:pocket_timetable/constants/routes.dart';
import 'package:pocket_timetable/constants/validation_cases.dart';
import 'package:pocket_timetable/models/university.dart';
import 'package:pocket_timetable/models/userdata.dart';

import '../constants/page_titles.dart';
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

    Map<String, String> headers = {
      Api.ngrokSkipWarningHeader: '10'
    };

    getDataFromServer(
        Api.universities, headers
    ).then((responseData) {
      if (mounted) {
        List<University> universities = responseData.map<University>((item) {
          return University.fromResponse(item);
        }).toList();

        setState(() {
          _universities = universities;
          _selectedUniversity = universities.isEmpty?
          null : _universities.first;
        });
      }
    });
  }

  void _userdataFormHandler() {
    if (_formKey.currentState!.validate()) {
      redirect(
          context,
          Routes.setGroup,
          Userdata.withNameAndUniversity(
              _usernameController.text.trim(),
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

  Widget _getUsernameField() {
    return TextFormField(
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
        style: Theme.of(context).textTheme.bodyMedium,
        textAlignVertical: TextAlignVertical.center,
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
            labelStyle: Theme.of(context).textTheme.labelMedium,
            floatingLabelAlignment:
            FloatingLabelAlignment.start,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.all(5.0)
        )
    );
  }

  Widget _getUniversitiesDropdown() {
    return DropdownButtonFormField(
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
          ),
          labelText: Labels.userUniversityLabel,
          labelStyle: Theme.of(context).textTheme.labelMedium,
          floatingLabelAlignment: FloatingLabelAlignment.start,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(5.0)
      ),
      value: _selectedUniversity?.id ?? 0,
      items: _universities.map((university) {
        return DropdownMenuItem(
          key: Key('university_${university.id}'),
          value: university.id,
          child: Text(
            _selectedUniversity?.id == university.id?
            university.shortName :
            '${university.name} (${university.shortName})',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      }).toList(),
      onChanged: (Object? value) {
        int selectedUniversityId = value as int;
        _dropdownButtonOnChangedHandler(selectedUniversityId);
      },
    );
  }

  Widget _getFormButton() {
    return ElevatedButton(
        key: const Key('continue_button'),
        onPressed: () {
          _userdataFormHandler();
        },
        style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.secondary,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
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
          style: Theme.of(context).textTheme.bodyLarge,
        )
    );
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
        )
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _getUsernameField(),
                        const SizedBox(height: 25),
                        _getUniversitiesDropdown(),
                        const SizedBox(height: 45),
                        SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 45
                              ),
                              child: _getFormButton(),
                            )
                        )
                      ],
                    ),
                  )
              )
          ),
        )
      )
    );
  }
}