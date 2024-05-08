import 'package:form_app/questions/question.dart';

class ShortAnswerQuestion extends Question {
  ShortAnswerQuestion({required super.question});

  @override
  dynamic toJson() {
    return {
      "QUESTION": question,
      "TYPE": "SHORT_ANSWER_RESPONSE"
    };
  }
}
