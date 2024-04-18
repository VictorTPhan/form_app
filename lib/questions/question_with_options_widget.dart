import 'package:form_app/questions/question_widget.dart';

class QuestionWithOptionsWidget extends QuestionWidget {
  final List<dynamic> options;

  QuestionWithOptionsWidget({super.key, required super.question, required this.options});

  @override
  QuestionWidgetState createState() => QuestionWithOptionsWidgetState();
}

class QuestionWithOptionsWidgetState extends QuestionWidgetState {

}