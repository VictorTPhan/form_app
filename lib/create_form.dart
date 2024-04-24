import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_fast_forms/flutter_fast_forms.dart';
import 'package:form_app/misc.dart';
import 'package:form_app/view_form.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'generated_form.dart';

class CreateForm extends StatefulWidget {
  const CreateForm({super.key});

  @override
  State<CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  final formKey = GlobalKey<FormState>();
  bool formValidated = false;
  UnmodifiableMapView<String, dynamic> currentFormResponse = UnmodifiableMapView({});

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

  Future<void> sendPostRequest() async {
    var url = Uri.parse('https://form-app-server-zibv.onrender.com/create_form/');

    var payload = {
      "GOAL": currentFormResponse["GOAL"].toString(),
      "PROBLEM": currentFormResponse["PROBLEM"].toString(),
      "FORM_LENGTH": currentFormResponse["FORM_LENGTH"].toString(),
      "ALLOWED_TYPES": currentFormResponse["ALLOWED_TYPES"].toString(),
      "SOLUTION_TASK": currentFormResponse["SOLUTION_TASK"].toString()
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

        print(jsonResponse);

        jsonResponse["GOAL"] = currentFormResponse["GOAL"].toString();
        jsonResponse["PROBLEM"] = currentFormResponse["PROBLEM"].toString();
        jsonResponse["FORM_LENGTH"] = currentFormResponse["FORM_LENGTH"].toString();
        jsonResponse["SOLUTION_TASK"] = currentFormResponse["SOLUTION_TASK"].toString();
        jsonResponse["ALLOWED_TYPES"] = currentFormResponse["ALLOWED_TYPES"].toList();

        // create a UUID to reference this by
        var uuidGenerator = const Uuid();
        var uuid = uuidGenerator.v4();
        jsonResponse["UUID"] = uuid.toString();

        final box = GetStorage();
        // save a copy of this form on disk casted as a Map
        box.write(uuid.toString(), jsonResponse as Map<String, dynamic>);

        // add a reference to this entry in a list
        List<dynamic> savedForms = box.read("SAVED_FORMS") ?? [];
        savedForms.add(uuid.toString());
        box.write("SAVED_FORMS", savedForms);

        var generatedForm = GeneratedForm.fromJson(jsonResponse);

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
        appBar: AppBar(
          toolbarHeight: 80,
          title: Text(
            style: standardTextStyle(fontSize: 25),
            "Let's Get Started"
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
                children: [
                  FastForm(
                    formKey: formKey,
                    children: [
                      const Text("You are trying to..."),
                      const FastTextField(
                        name: "GOAL",
                        minLines: 1,
                        maxLines: 1,
                      ),
                      const Text("What's the problem?"),
                      const FastTextField(
                        name: "PROBLEM",
                        minLines: 1,
                        maxLines: 1,
                      ),
                      const Text("What do you need?"),
                      const FastTextField(
                        name: "SOLUTION_TASK",
                        minLines: 1,
                        maxLines: 1,
                      ),
                      const Text("How many questions do you want to answer?"),
                      const FastTextField(
                        name: "FORM_LENGTH",
                        minLines: 1,
                        maxLines: 1,
                      ),
                      const Text("What kind of questions do you want to answer?"),
                      FastChoiceChips(
                          name: "ALLOWED_TYPES",
                          chips: [
                            FastChoiceChip(
                              selected: true,
                              label: const Text("Short Answer"),
                              value: "SHORT_ANSWER_RESPONSE",
                            ),
                            FastChoiceChip(
                              selected: true,
                              label: const Text("Long Answer"),
                              value: "LONG_ANSWER_RESPONSE",
                            ),
                            FastChoiceChip(
                              selected: true,
                              label: const Text("Multiple Choice"),
                              value: "MULTIPLE_CHOICE",
                            ),
                            FastChoiceChip(
                              selected: true,
                              label: const Text("Checkbox"),
                              value: "CHECKBOX",
                            )
                          ]
                      )
                    ],
                    onChanged: (UnmodifiableMapView<String, dynamic> responses) {
                      setState(() {
                        formValidated = isFormValidated(responses);
                        currentFormResponse = responses;
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
