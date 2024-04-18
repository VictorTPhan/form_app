import 'package:flutter/material.dart';
import 'package:form_app/questions/question_widget.dart';
import 'package:form_app/questions/question_with_options_widget.dart';

class MultipleChoiceQuestionWidget extends QuestionWithOptionsWidget {
  MultipleChoiceQuestionWidget({required String question, required List<dynamic> options}): super(question: question, options: options);

  @override
  QuestionWidgetState createState() => _MultipleChoiceQuestionWidgetState();
}

class _MultipleChoiceQuestionWidgetState extends QuestionWithOptionsWidgetState {
  String _selectedOption = '';

  @override
  Widget displayAnswer() {
    return Column(
      children: (widget as MultipleChoiceQuestionWidget).options.map((option) {
        return RadioListTile(
          title: Text(option.toString()),
          value: option,
          groupValue: _selectedOption,
          onChanged: (value) {
            setState(() {
              _selectedOption = value.toString();
            });
          },
        );
      }).toList(),
    );
  }
}