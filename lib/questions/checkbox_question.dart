import 'package:form_app/questions/question_with_options.dart';

class CheckboxQuestion extends QuestionWithOptions {
  CheckboxQuestion({required super.question, required super.options});

  dynamic toJson() {
    return {
      "QUESTION": question,
      "OPTIONS": options,
      "TYPE": "CHECKBOX"
    };
  }
}
