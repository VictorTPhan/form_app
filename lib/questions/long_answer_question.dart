import 'package:form_app/questions/question.dart';

class LongAnswerQuestion extends Question {
  LongAnswerQuestion({required super.question});

  dynamic toJson() {
    return {
      "QUESTION": question,
      "TYPE": "LONG_ANSWER_RESPONSE"
    };
  }
}
