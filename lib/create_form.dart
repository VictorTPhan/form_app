import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
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
  final List<Map<String, String>> examples = [
    {
      "goal": "cook some food for a potluck",
      "problem": "I'm really bad at cooking",
      "task": "a recipe I can easily make"
    },
    {
      "goal": "plan a summer vacation",
      "problem": "I'm not sure what to do or where to go",
      "task": "a travel itinerary"
    },
    {
      "goal": "find an interesting book to read",
      "problem": "I don't know what to choose",
      "task": "a suggestion on a good read"
    },
    {
      "goal": "study for an upcoming final",
      "problem": "I can't concentrate",
      "task": "a solid study plan based around my schedule"
    },
    {
      "goal": "understand something from my calculus class",
      "problem": "My professor's notes are bad and I don't get it",
      "task": "a simple explanation on a particular calculus concept"
    },
    {
      "goal": "write a letter to my boss",
      "problem": "I'm not sure how I should word it",
      "task": "A professional email template that I could use"
    },
    {
      "goal": "write an email to an angry client",
      "problem": "I'm not good at customer service",
      "task": "A professional email template that I could use"
    },
    {
      "goal": "write a scholarship application",
      "problem": "I'm bad at writing application essays",
      "task": "Things I could write about/an essay about my strengths"
    },
    {
      "goal": "practice interviewing for a job",
      "problem": "The interviews are really hard",
      "task": "A practice regiment for me to prepare for an interview"
    },
    {
      "goal": "find a job with my major",
      "problem": "It's super hard finding a job right now",
      "task": "Potential places to look for a job"
    },
  ];

  final formKey = GlobalKey<FormState>();
  bool formValidated = false;
  UnmodifiableMapView<String, dynamic> currentFormResponse = UnmodifiableMapView({});
  late Map<String, String> example = examples[Random().nextInt(examples.length)];
  int delayIncrease = 200;
  late int delay = -delayIncrease;

  Widget createWidgetWithDelay(Widget child) {
    delay += delayIncrease;

    return FadeInLeft(
      delay: Duration(milliseconds: delay),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }

  Widget createFormQuestion(String question, Widget formWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedTextKit(
          isRepeatingAnimation: false,
          animatedTexts: [
            TypewriterAnimatedText(
              speed: const Duration(milliseconds: 50),
              textStyle: standardTextStyle(),
              question
            ),
          ],
        ),
        formWidget
      ],
    );
  }

  bool isFormValidated(UnmodifiableMapView<String, dynamic> responses) {
    for (String question in responses.keys) {
      var response = responses[question];
      
      // special case -- "FORM_LENGTH" != 0
      if (question == "FORM_LENGTH") {
        dynamic parseResult = int.tryParse(response);
        if (parseResult == null || parseResult <= 0) {
          return false;
        }
      }

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
                      createWidgetWithDelay(
                        createFormQuestion(
                          "You are trying to...",
                          FastTextField(
                            name: "GOAL",
                            placeholder: example["goal"],
                            minLines: 1,
                            maxLines: 1,
                          ),
                        )
                      ),
                      createWidgetWithDelay(
                          createFormQuestion(
                            "What's the problem?",
                            FastTextField(
                              name: "PROBLEM",
                              placeholder: example["problem"],
                              minLines: 1,
                              maxLines: 1,
                            ),
                          )
                      ),
                      createWidgetWithDelay(
                          createFormQuestion(
                            "What do you need?",
                            FastTextField(
                              name: "SOLUTION_TASK",
                              placeholder: example["task"],
                              minLines: 1,
                              maxLines: 1,
                            ),
                          )
                      ),
                      createWidgetWithDelay(
                          createFormQuestion(
                            "How many questions do you want to answer?",
                            const FastTextField(
                              name: "FORM_LENGTH",
                              placeholder: "5",
                              keyboardType: TextInputType.number,
                              minLines: 1,
                              maxLines: 1,
                            ),
                          )
                      ),
                      createWidgetWithDelay(
                          createFormQuestion(
                            "What kind of questions do you want to answer?",
                              FastChoiceChips(
                                  name: "ALLOWED_TYPES",
                                  chips: [
                                    FastChoiceChip(
                                      selected: true,
                                      label: Text(
                                          style: standardTextStyle(),
                                          "Short Answer"
                                      ),
                                      value: "SHORT_ANSWER_RESPONSE",
                                    ),
                                    FastChoiceChip(
                                      selected: true,
                                      label: Text(
                                          style: standardTextStyle(),
                                          "Long Answer"
                                      ),
                                      value: "LONG_ANSWER_RESPONSE",
                                    ),
                                    FastChoiceChip(
                                      selected: true,
                                      label: Text(
                                          style: standardTextStyle(),
                                          "Multiple Choice"
                                      ),
                                      value: "MULTIPLE_CHOICE",
                                    ),
                                    FastChoiceChip(
                                      selected: true,
                                      label: Text(
                                          style: standardTextStyle(),
                                          "Checkbox"
                                      ),
                                      value: "CHECKBOX",
                                    )
                                  ]
                              )
                          )
                      ),
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
                        child: Text(
                          style: standardTextStyle(),
                          "Let's Go"
                        )
                    )
                ]
            ),
          ),
        )
    );
  }
}
