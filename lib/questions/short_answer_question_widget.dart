import 'package:flutter/material.dart';
import 'package:form_app/questions/question_widget.dart';

class ShortAnswerQuestionWidget extends QuestionWidget {
  ShortAnswerQuestionWidget({required super.key, required String question}) : super(question: question);

  @override
  QuestionWidgetState createState() => _ShortAnswerQuestionWidgetState();
}

class _ShortAnswerQuestionWidgetState extends QuestionWidgetState {
  TextEditingController controller = TextEditingController();

  @override
  bool isFilledIn() {
    return controller.text.isNotEmpty;
  }

  @override
  dynamic getChoice() {
    return {
      "question": widget.question,
      "answer": controller.text
    };
  }

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