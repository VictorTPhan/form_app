import 'package:flutter/material.dart';
import 'package:form_app/questions/question_widget.dart';
import 'package:form_app/questions/question_with_options_widget.dart';

class CheckboxQuestionWidget extends QuestionWithOptionsWidget {
  CheckboxQuestionWidget({required super.key, required String question, required List<dynamic> options}): super(question: question, options: options);

  @override
  QuestionWidgetState createState() => _CheckboxQuestionWidgetState();
}

class _CheckboxQuestionWidgetState extends QuestionWithOptionsWidgetState {
  Set<String> selectedChoices = {};
  Map<String, bool> checkboxes = {};

  @override
  bool isFilledIn() {
    return selectedChoices.isNotEmpty;
  }

  @override
  dynamic getChoice() {
    return {
      "question": widget.question,
      "answer": selectedChoices.toList().toString()
    };
  }

  @override
  Widget displayAnswer() {
    return Column(
      children: (widget as CheckboxQuestionWidget).options.map((option) {
        checkboxes.putIfAbsent(option.toString(), () => false);
        return CheckboxListTile(
          title: Text(option.toString()),
          value: checkboxes[option.toString()]!,
          onChanged: (value) {
            setState(() {
              checkboxes[option.toString()] = value!;
              for (String questionType in checkboxes.keys) {
                if (checkboxes[questionType]!) {
                  selectedChoices.add(questionType);
                }
              }
            });
          },
        );
      }).toList(),
    );
  }
}
