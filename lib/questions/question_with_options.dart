import 'package:form_app/questions/question.dart';

abstract class QuestionWithOptions extends Question {
  late List<dynamic> options;

  QuestionWithOptions({required super.question, required this.options});
}
