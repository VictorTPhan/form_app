import 'package:form_app/questions/question.dart';

class QuestionWithOptions extends Question {
  late List<dynamic> options;

  QuestionWithOptions({required super.question, required this.options});
}
