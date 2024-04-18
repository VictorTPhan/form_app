import 'package:flutter/material.dart';
import 'package:form_app/questions/question_widget.dart';

class ShortAnswerQuestionWidget extends QuestionWidget {
  ShortAnswerQuestionWidget({super.key, required String question}) : super(question: question);

  @override
  QuestionWidgetState createState() => _ShortAnswerQuestionWidgetState();
}

class _ShortAnswerQuestionWidgetState extends QuestionWidgetState {
  TextEditingController controller = TextEditingController();

  @override
  Widget displayAnswer() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {

        });
      },
      controller: controller,
    );
  }
}