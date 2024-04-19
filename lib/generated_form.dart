import 'package:flutter/cupertino.dart';
import 'package:form_app/questions/checkbox_question_widget.dart';
import 'package:form_app/questions/long_answer_question_widget.dart';
import 'package:form_app/questions/multiple_choice_question_widget.dart';
import 'package:form_app/questions/question_widget.dart';
import 'package:form_app/questions/short_answer_question_widget.dart';

class GeneratedForm {
  late String goal;
  late String problem;
  late String formLength;
  late String solutionTask;
  late List<dynamic> allowedTypes;

  late String name;
  late List<QuestionWidget> questions;

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
      final GlobalKey<QuestionWidgetState> questionKey = GlobalKey<QuestionWidgetState>();

      switch(questionJSON['type']) {
        case "SHORT_ANSWER_RESPONSE":
          questions.add(
            ShortAnswerQuestionWidget(
              key: questionKey,
              question: questionJSON['question']
            )
          );
          continue;
        case "LONG_ANSWER_RESPONSE":
          questions.add(
            LongAnswerQuestionWidget(
              key: questionKey,
              question: questionJSON['question']
            )
          );
          continue;
        case "MULTIPLE_CHOICE":
          questions.add(
            MultipleChoiceQuestionWidget(
              key: questionKey,
              question: questionJSON['question'],
              options: questionJSON['options']
            )
          );
          continue;
        case "CHECKBOX":
          questions.add(
            CheckboxQuestionWidget(
              key: questionKey,
              question: questionJSON['question'],
              options: questionJSON['options']
            )
          );
          continue;
      }
    }
  }
}