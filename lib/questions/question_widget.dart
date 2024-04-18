import 'package:flutter/material.dart';

class QuestionWidget extends StatefulWidget {
  final String question;

  const QuestionWidget({super.key, required this.question});

  @override
  QuestionWidgetState createState() => QuestionWidgetState();
}

class QuestionWidgetState extends State<QuestionWidget> {
  Widget displayAnswer() {
    return Container();
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