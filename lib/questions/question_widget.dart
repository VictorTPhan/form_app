import 'package:flutter/material.dart';

class QuestionWidget extends StatefulWidget {
  final String question;
  final GlobalKey<QuestionWidgetState> key;

  const QuestionWidget({required this.key, required this.question}) : super(key: key);

  @override
  QuestionWidgetState createState() => QuestionWidgetState();
}

class QuestionWidgetState extends State<QuestionWidget> {
  Widget displayAnswer() {
    return Container();
  }

  bool isFilledIn() {
    return false;
  }

  dynamic getChoice() {
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.question),
        displayAnswer()
      ],
    );
  }
}