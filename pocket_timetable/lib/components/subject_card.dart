import 'package:flutter/material.dart';

import '../constants/labels.dart';
import '../models/subject.dart';
import '../utils.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final String subjectKey;
  final LinearGradient cardColor;
  final double cardMargin;

  const SubjectCard({Key? key, required this.subject,
  required this.subjectKey, required this.cardColor,
    required this.cardMargin}): super(key: key);

  bool _isSubjectActive(Subject subject) {
    DateTime currentDateTime = DateTime.now();
    int currentSeconds = currentDateTime.hour * 3600 +
        currentDateTime.minute * 60;

    return currentSeconds >= subject.timeStart &&
        currentSeconds <= subject.timeEnd;
  }

  Widget _getSubjectCard(BuildContext context) {
    String subjectTimeStart = getTimeFromSeconds(subject.timeStart);
    String subjectTimeEnd = getTimeFromSeconds(subject.timeEnd);
    bool isActive = _isSubjectActive(subject);

    List<Widget> leftColumnChildren = [
      Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$subjectTimeStart - $subjectTimeEnd',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.visible,
            ),
          )
      )];
    if (subject.tutor.isNotEmpty) {
      leftColumnChildren.add(Expanded(
        child: Padding(
          padding: const EdgeInsets.only(
              top: 20
          ),
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
      ));
    }

    List<Widget> rightColumnChildren = [
      Align(
        alignment: Alignment.centerRight,
        child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
                horizontal: 10
            ),
            height: 20,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20)
                )
            ),
            child: Text(
              Labels.subjectIsActiveLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.visible,
            )
        ),
      ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(
              right: 10,
              top: isActive? 9 : subject.tutor.isNotEmpty? 10 : 0
          ),
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
      )
    ];
    if (!isActive) {
      rightColumnChildren.removeAt(0);
    }

    return Padding(
        key: Key(subjectKey),
        padding: const EdgeInsets.only(
            bottom: 10
        ),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            margin: EdgeInsets.all(cardMargin),
            decoration: BoxDecoration(
                gradient: cardColor,
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: leftColumnChildren,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: isActive? 8 : 10,
                              bottom: 10,
                              left: 10
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: rightColumnChildren,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10
                  ),
                  child: Text(
                    subject.subjectType,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getSubjectCard(context);
  }
}