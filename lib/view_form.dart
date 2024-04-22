import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_app/generated_form.dart';
import 'package:form_app/questions/question_widget.dart';
import 'package:form_app/response.dart';
import 'package:http/http.dart' as http;

import 'misc.dart';

class ViewForm extends StatefulWidget {
  ViewForm({super.key, required this.generatedForm});

  GeneratedForm generatedForm;

  @override
  State<ViewForm> createState() => _ViewFormState();
}

class _ViewFormState extends State<ViewForm> {

  bool formValidated() {
    for (QuestionWidget question in widget.generatedForm.questions) {
      QuestionWidgetState? widgetState = question.key.currentState;
      if (widgetState == null || !widgetState.isFilledIn()) {
        return false;
      }
    }
    return true;
  }

  List<dynamic> getResponses() {
    List<dynamic> output = [];
    for (QuestionWidget question in widget.generatedForm.questions) {
      if (question.key.currentState!.isFilledIn()) {
        output.add(question.key.currentState!.getChoice());
      }
    }
    return output;
  }

  Future<void> sendPostRequest() async {
    var url = Uri.parse('https://form-app-server-zibv.onrender.com/submit_form/');

    var payload = {
      "GOAL": widget.generatedForm.goal,
      "PROBLEM": widget.generatedForm.problem,
      "SOLUTION_TASK": widget.generatedForm.solutionTask,
      "RESPONSES": getResponses().toString()
    };
    var body = json.encode(payload);
    print(body);

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add any additional headers if needed
        },
        body: body,
      );
      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        // var jsonResponse = json.decode(response.body);
        navigateTo(context, ResponsePage(response: response.body));
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.generatedForm.name),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: widget.generatedForm.questions.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == widget.generatedForm.questions.length) {
                if (formValidated()) {
                  return ElevatedButton(
                    onPressed: () {
                      sendPostRequest();
                    },
                    child: Text("Let's Go")
                  );
                }
              }
              else {
                return widget.generatedForm.questions[index];
              }
            },
          ),
        ]
      )
    );
  }
}
