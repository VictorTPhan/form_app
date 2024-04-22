import 'package:flutter/cupertino.dart';
import 'package:form_app/questions/checkbox_question.dart';
import 'package:form_app/questions/long_answer_question.dart';
import 'package:form_app/questions/multiple_choice_question.dart';
import 'package:form_app/questions/question.dart';
import 'package:form_app/questions/short_answer_question.dart';

class GeneratedForm {
  late String goal;
  late String problem;
  late String formLength;
  late String solutionTask;
  late List<dynamic> allowedTypes;

  late String name;
  late List<Question> questions;

  GeneratedForm({
    required this.name,
    required this.questions,
    required this.goal,
    required this.problem,
    required this.formLength,
    required this.solutionTask,
    required this.allowedTypes
  });

  GeneratedForm.fromJson(Map<String, dynamic> json,
    this.goal, this.problem, this.formLength,
    this.solutionTask, this.allowedTypes
    ) {
    name = json['form_name'];
    questions = []; // must initialize questions first
    List<dynamic> encodedQuestions = json['questions'];
    for (dynamic questionJSON in encodedQuestions) {
      switch(questionJSON['type']) {
        case "SHORT_ANSWER_RESPONSE":
          questions.add(
            ShortAnswerQuestion(
              question: questionJSON['question']
            )
          );
          continue;
        case "LONG_ANSWER_RESPONSE":
          questions.add(
            LongAnswerQuestion(
              question: questionJSON['question']
            )
          );
          continue;
        case "MULTIPLE_CHOICE":
          questions.add(
            MultipleChoiceQuestion(
              question: questionJSON['question'],
              options: questionJSON['options']
            )
          );
          continue;
        case "CHECKBOX":
          questions.add(
            CheckboxQuestion(
              question: questionJSON['question'],
              options: questionJSON['options']
            )
          );
          continue;
      }
    }
  }
}