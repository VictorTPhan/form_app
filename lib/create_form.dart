import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_app/misc.dart';
import 'package:form_app/view_form.dart';
import 'package:http/http.dart' as http;

import 'generated_form.dart';

class CreateForm extends StatefulWidget {
  const CreateForm({super.key});

  @override
  State<CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  TextEditingController goalController = new TextEditingController();
  TextEditingController problemController = new TextEditingController();
  TextEditingController formLengthController = new TextEditingController();
  TextEditingController solutionController = new TextEditingController();
  Set<String> questionTypes = {};

  Map<String, bool> checkboxes = {
    'Short Answer': false,
    'Long Answer': false,
    'Multiple Choice': false,
    'Checkboxes': false,
  };

  Map<String, String> labelToValue = {
    'Short Answer': "SHORT_ANSWER_RESPONSE",
    'Long Answer': "LONG_ANSWER_RESPONSE",
    'Multiple Choice': "MULTIPLE_CHOICE",
    'Checkboxes': "CHECKBOX",
  };

  bool formValidated() {
    return goalController.text.isNotEmpty
        && problemController.text.isNotEmpty
        && formLengthController.text.isNotEmpty
        && solutionController.text.isNotEmpty
        && questionTypes.isNotEmpty;
  }

  Future<void> sendPostRequest() async {
    var url = Uri.parse('https://form-app-server-zibv.onrender.com/create_form/');

    var payload = {
      // "GOAL": goalController.text,
      // "PROBLEM": problemController.text,
      // "FORM_LENGTH": formLengthController.text,
      // "ALLOWED_TYPES": questionTypes.toList().toString(),
      // "SOLUTION_TASK": solutionController.text
      "GOAL": "To cook some food for a potluck",
      "PROBLEM": "I am not good at cooking",
      "FORM_LENGTH": "5",
      "ALLOWED_TYPES": "[SHORT_ANSWER_RESPONSE, LONG_ANSWER_RESPONSE, MULTIPLE_CHOICE, CHECKBOX]",
      "SOLUTION_TASK": "a recipe that I can make easily and quickly"
    };
    var body = json.encode(payload);

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
        var jsonResponse = json.decode(response.body);
        var generatedForm = GeneratedForm.fromJson(
          jsonResponse,
          goalController.text,
          problemController.text,
          formLengthController.text,
          solutionController.text,
          questionTypes.toList()
        );
        navigateTo(context, ViewForm(generatedForm: generatedForm));
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Create a Form"),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'to cook some food...',
              labelText: 'What do you want to do?',
              border: OutlineInputBorder(),
            ),
            controller: goalController,
            onChanged: (value) {
              setState(() {

              });
            },
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "I can't cook...",
              labelText: "What's the problem?",
              border: OutlineInputBorder(),
            ),
            controller: problemController,
            onChanged: (value) {
              setState(() {

              });
            },
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "A game plan, a checklist, advice, an opinion...",
              labelText: "What do you want to know?",
              border: OutlineInputBorder(),
            ),
            controller: solutionController,
            onChanged: (value) {
              setState(() {

              });
            },
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "5-7",
              labelText: "How many questions do you want to answer?",
              border: OutlineInputBorder(),
            ),
            controller: formLengthController,
            onChanged: (value) {
              setState(() {

              });
            },
          ),
          Text("What kind of questions do you want to answer?"),
          ListView(
            shrinkWrap: true,
            children: checkboxes.keys.map((String title) {
              return CheckboxListTile(
                title: Text(title),
                value: checkboxes[title],
                onChanged: (bool? value) {
                  setState(() {
                    checkboxes[title] = value!;
                    for (String questionType in checkboxes.keys) {
                      if (checkboxes[questionType]!) {
                        questionTypes.add(labelToValue[questionType]!);
                      }
                    }
                  });
                },
              );
            }).toList(),
          ),
          // if (formValidated())
            ElevatedButton(
                onPressed: () {
                  sendPostRequest();
                },
                child: Text("Let's Go")
            )
        ],
      ),
    );
  }
}
