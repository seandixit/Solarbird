import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:survey_kit/survey_kit.dart';


class ObserveTab extends StatefulWidget {
  const ObserveTab({Key? key}) : super(key: key);

  @override
  State<ObserveTab> createState() => _ObserveTabState();
}

class _ObserveTabState extends State<ObserveTab> {
  Task task = getTask();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SurveyKit(
            task: task,
            onResult: (SurveyResult result){
              final jsonResult = result.toJson();
              debugPrint(jsonEncode(jsonResult));
              setState(() {
              });
            },
            showProgress: true,
            localizations: const {
              'cancel': 'Cancel',
              'next': 'Next',
            },
          )
        ),
    );
  }
}

getTask() {
  var task = NavigableTask(
    id: TaskIdentifier(),
    steps: [
      QuestionStep(
        title: 'How old are you?',
        answerFormat: const IntegerAnswerFormat(
          defaultValue: 25,
          hint: 'Please enter your age',
        ),
      ),
      CompletionStep(
        title: 'You are done',
        text: 'You have finished !!!',
        buttonText: 'Submit survey',
        stepIdentifier: StepIdentifier(id: "1"),

      )
    ]
  );
  return task;
}