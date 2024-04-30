import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:form_app/questions/checkbox_question.dart';
import 'package:form_app/questions/long_answer_question.dart';
import 'package:form_app/questions/multiple_choice_question.dart';
import 'package:form_app/questions/question.dart';
import 'package:form_app/questions/short_answer_question.dart';

import 'misc.dart';

class GeneratedForm {
  late String goal;
  late String problem;
  late String formLength;
  late String solutionTask;
  late List<dynamic> allowedTypes;
  late int colorIndex;

  late String uuid;
  late String name;
  late String emoji;
  late List<Question> questions;

  GeneratedForm({
    required this.uuid,
    required this.name,
    required this.emoji,
    required this.questions,
    required this.goal,
    required this.problem,
    required this.formLength,
    required this.solutionTask,
    required this.allowedTypes
  });

  GeneratedForm.fromJson(Map<String, dynamic> json) {
    goal = json["GOAL"];
    problem = json["PROBLEM"];
    formLength = json["FORM_LENGTH"];
    solutionTask = json["SOLUTION_TASK"];
    allowedTypes = json["ALLOWED_TYPES"];
    colorIndex = json["COLOR_INDEX"];

    uuid = json["UUID"];
    emoji = json["EMOJI"];
    name = json['FORM_NAME'];
    questions = []; // must initialize questions first
    List<dynamic> encodedQuestions = json['QUESTIONS'];
    print(encodedQuestions);

    for (dynamic questionJSON in encodedQuestions) {
      switch(questionJSON['TYPE']) {
        case "SHORT_ANSWER_RESPONSE":
          questions.add(
            ShortAnswerQuestion(
              question: questionJSON['QUESTION']
            )
          );
          continue;
        case "LONG_ANSWER_RESPONSE":
          questions.add(
            LongAnswerQuestion(
              question: questionJSON['QUESTION']
            )
          );
          continue;
        case "MULTIPLE_CHOICE":
          questions.add(
            MultipleChoiceQuestion(
              question: questionJSON['QUESTION'],
              options: questionJSON['OPTIONS']
            )
          );
          continue;
        case "CHECKBOX":
          questions.add(
            CheckboxQuestion(
              question: questionJSON['QUESTION'],
              options: questionJSON['OPTIONS']
            )
          );
          continue;
      }
    }
  }

  dynamic toJson() {
    return {
      "FORM_NAME": name,
      "EMOJI": emoji,
      "QUESTIONS": questions.map((question) => question.toJson()).toList(),
      "GOAL": goal,
      "PROBLEM": problem,
      "FORM_LENGTH": formLength,
      "SOLUTION_TASK": solutionTask,
      "ALLOWED_TYPES": allowedTypes,
      "COLOR_INDEX": colorIndex,
    };
  }
}