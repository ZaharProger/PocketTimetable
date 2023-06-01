import 'package:flutter/material.dart';
import 'package:pocket_timetable/constants/page_titles.dart';
import 'package:pocket_timetable/constants/routes.dart';
import 'package:pocket_timetable/models/userdata.dart';
import 'package:pocket_timetable/pages/home_page.dart';
import 'package:pocket_timetable/pages/set_group_page.dart';

void main() {
  runApp(const PocketTimetableApp());
}

class PocketTimetableApp extends StatelessWidget {
  const PocketTimetableApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: PageTitles.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 23, 39, 44),
          secondary: const Color.fromARGB(255, 255, 255, 255),
          onPrimary: const Color.fromARGB(255, 0, 134, 163),
          onPrimaryContainer: const Color.fromARGB(255, 54, 189, 67),
          onError: Colors.red,
          tertiary: const Color.fromARGB(255, 121, 165, 174),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color.fromARGB(255, 255, 255, 255),
          selectionColor: Color.fromARGB(255, 0, 134, 163),
          selectionHandleColor: Color.fromARGB(255, 255, 255, 255),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
          bodyLarge: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 16,
              letterSpacing: 1,
              overflow: TextOverflow.ellipsis
          ),
          bodyMedium: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 14
          ),
          bodySmall: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 12
          ),
          labelMedium: TextStyle(
            color: Color.fromARGB(100, 255, 255, 255),
            fontSize: 14
          )
        )
      ),
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case Routes.setGroup:
            Userdata userdata = settings.arguments as Userdata;
            page = SetGroupPage(userdata: userdata);
            break;
          default:
            page = const HomePage();
            break;
        }

        return MaterialPageRoute(
          builder: (context) {
            return page;
          }
        );
      },
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
