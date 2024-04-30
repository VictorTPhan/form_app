import 'package:form_app/questions/question_with_options.dart';

class MultipleChoiceQuestion extends QuestionWithOptions {
  MultipleChoiceQuestion({required super.question, required super.options});

  @override
  dynamic toJson() {
    return {
      "QUESTION": question,
      "OPTIONS": options,
      "TYPE": "MULTIPLE_CHOICE",
    };
  }
}
