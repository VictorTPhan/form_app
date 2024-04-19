import 'package:flutter/material.dart';
import 'package:form_app/questions/question_widget.dart';

class LongAnswerQuestionWidget extends QuestionWidget {
  LongAnswerQuestionWidget({required super.key, required String question}) : super(question: question);

  @override
  QuestionWidgetState createState() => LongAnswerQuestionWidgetState();
}

class LongAnswerQuestionWidgetState extends QuestionWidgetState {
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
      minLines: 5,
      maxLines: 10,
    );
  }
}