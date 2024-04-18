import 'package:form_app/questions/checkbox_question_widget.dart';
import 'package:form_app/questions/long_answer_question_widget.dart';
import 'package:form_app/questions/multiple_choice_question_widget.dart';
import 'package:form_app/questions/question_widget.dart';
import 'package:form_app/questions/short_answer_question_widget.dart';

class GeneratedForm {
  late String name;
  late List<QuestionWidget> questions;

  GeneratedForm({required this.name, required this.questions});

  GeneratedForm.fromJson(Map<String, dynamic> json) {
    name = json['form_name'];
    questions = []; // must initialize questions first
    List<dynamic> encodedQuestions = json['questions'];
    for (dynamic questionJSON in encodedQuestions) {
      switch(questionJSON['type']) {
        case "SHORT_ANSWER_RESPONSE":
          questions.add(ShortAnswerQuestionWidget(question: questionJSON['question']));
          continue;
        case "LONG_ANSWER_RESPONSE":
          questions.add(LongAnswerQuestionWidget(question: questionJSON['question']));
          continue;
        case "MULTIPLE_CHOICE":
          questions.add(MultipleChoiceQuestionWidget(question: questionJSON['question'],
              options: questionJSON['options']));
          continue;
        case "CHECKBOX":
          questions.add(CheckboxQuestionWidget(question: questionJSON['question'],
              options: questionJSON['options']));
          continue;
      }
    }
  }
}