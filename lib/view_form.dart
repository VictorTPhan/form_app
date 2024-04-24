import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_fast_forms/flutter_fast_forms.dart';
import 'package:form_app/generated_form.dart';
import 'package:form_app/questions/checkbox_question.dart';
import 'package:form_app/questions/long_answer_question.dart';
import 'package:form_app/questions/multiple_choice_question.dart';
import 'package:form_app/questions/question.dart';
import 'package:form_app/questions/short_answer_question.dart';
import 'package:form_app/response.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'generated_response.dart';
import 'misc.dart';

class ViewForm extends StatefulWidget {
  ViewForm({super.key, required this.generatedForm});

  GeneratedForm generatedForm;

  @override
  State<ViewForm> createState() => _ViewFormState();
}

class _ViewFormState extends State<ViewForm> {
  final formKey = GlobalKey<FormState>();
  bool formValidated = false;
  String currentFormResponseString = "";

  bool isFormValidated(UnmodifiableMapView<String, dynamic> responses) {
    for (String question in responses.keys) {
      var response = responses[question];
      if (response is String && response.isEmpty ||
          response is Set && response.isEmpty) {
        return false;
      }
    }
    return true;
  }

  Widget buildQuestion(index) {
    Question currentQuestion = widget.generatedForm.questions[index];

    Widget inputWidget;

    // Would have used a switch case.
    if (currentQuestion is ShortAnswerQuestion) {
      inputWidget = FastTextField(
        name: currentQuestion.question,
        minLines: 1,
        maxLines: 1,
      );
    } else if (currentQuestion is LongAnswerQuestion) {
      inputWidget = FastTextField(
        name: currentQuestion.question,
        minLines: 5,
        maxLines: 10,
      );
    } else if (currentQuestion is MultipleChoiceQuestion) {
      List<FastRadioOption> options = [];
      for (String option in currentQuestion.options) {
        options.add(
            FastRadioOption(
                title: Text(option),
                value: option
            )
        );
      }

      inputWidget = FastRadioGroup(
          name: currentQuestion.question,
          options: options
      );
    } else if (currentQuestion is CheckboxQuestion) {
      List<FastChoiceChip> options = [];
      for (String option in currentQuestion.options) {
        options.add(
            FastChoiceChip(
              selected: false,
              value: option,
            )
        );
      }

      inputWidget = FastChoiceChips(
          name: currentQuestion.question,
          chips: options
      );
    } else {
      inputWidget = Container();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            style: standardTextStyle(),
            currentQuestion.question
          ),
          inputWidget
        ],
      ),
    );
  }

  Future<void> sendPostRequest() async {
    var url = Uri.parse('https://form-app-server-zibv.onrender.com/submit_form/');

    var payload = {
      "GOAL": widget.generatedForm.goal,
      "PROBLEM": widget.generatedForm.problem,
      "SOLUTION_TASK": widget.generatedForm.solutionTask,
      "RESPONSES": currentFormResponseString
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
        var jsonResponse = json.decode(response.body);

        final box = GetStorage();

        // generate a UUID for the response
        var uuidGenerator = const Uuid();
        var responseUUID = uuidGenerator.v4();

        // save the response
        box.write(responseUUID.toString(), jsonResponse);

        // add this response a list referencing this form
        String address = "${widget.generatedForm.uuid}/responses";
        List<dynamic> formResponses = box.read(address) ?? [];
        formResponses.add(responseUUID.toString());
        box.write(address, formResponses);

        // view the response
        navigateTo(context, ResponsePage(responseUUID: responseUUID));
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
        toolbarHeight: 80,
        title: Text(
            style: standardTextStyle(fontSize: 25),
            widget.generatedForm.name
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FastForm(
                formKey: formKey,
                children: List.generate(widget.generatedForm.questions.length, (index) => buildQuestion(index)).toList(),
                onChanged: (UnmodifiableMapView<String, dynamic> responses) {
                  setState(() {
                    formValidated = isFormValidated(responses);
                    currentFormResponseString = responses.toString();
                  });
                },
              ),
              if (formValidated)
                ElevatedButton(
                  onPressed: () {
                    sendPostRequest();
                  },
                  child: Text("Let's Go")
                )
            ]
          ),
        ),
      )
    );
  }
}
