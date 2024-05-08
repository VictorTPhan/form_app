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

  /// A list of examples that are used to fill in as placeholders
  /// for the TextFields on this screen.
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

  /// The [GlobalKey] used by the form on this screen to validate the form.
  final formKey = GlobalKey<FormState>();

  /// A boolean representing if the form on this screen is validated.
  bool formValidated = false;

  /// A map representation of the responses in this form. It is updated whenever
  /// the user modifies the form by inputting something.
  UnmodifiableMapView<String, dynamic> currentFormResponse = UnmodifiableMapView({});

  /// The example placeholder text chosen to fill in the TextFields on this page.
  late Map<String, String> example = examples[Random().nextInt(examples.length)];

  /// The amount of milliseconds to increase the delay by every time a widget
  /// is loaded.
  int delayIncrease = 200;

  /// The amount of milliseconds to delay a widget by when it loads.
  late int delay = -delayIncrease;

  /// Takes the [child] and houses it within a [FadeIn] widget with a delay.
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

  /// Generates a question for a [Question]'s question field and the [formWidget]
  /// associated with the question.
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

  /// Determines if the form on this page is filled in properly.
  bool isFormValidated(UnmodifiableMapView<String, dynamic> responses) {
    // Look through every question.
    for (String question in responses.keys) {
      var response = responses[question];

      // There is a special case "FORM_LENGTH" cannot be 0 or not a number
      if (question == "FORM_LENGTH") {
        dynamic parseResult = int.tryParse(response);
        if (parseResult == null || parseResult <= 0) {
          return false;
        }
      }

      // Generally, just check if the question is filled in
      if (response is String && response.isEmpty ||
          response is Set && response.isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Sends a POST request to the Formerly server to generate a form.
  Future<void> sendPostRequest() async {
    var url = Uri.parse('https://form-app-server-zibv.onrender.com/create_form/');

    // Create the payload.
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
        // Decode the response and add any additional fields.
        var jsonResponse = json.decode(response.body);
        jsonResponse["GOAL"] = currentFormResponse["GOAL"].toString();
        jsonResponse["PROBLEM"] = currentFormResponse["PROBLEM"].toString();
        jsonResponse["FORM_LENGTH"] = currentFormResponse["FORM_LENGTH"].toString();
        jsonResponse["SOLUTION_TASK"] = currentFormResponse["SOLUTION_TASK"].toString();
        jsonResponse["ALLOWED_TYPES"] = currentFormResponse["ALLOWED_TYPES"].toList();
        jsonResponse["COLOR_INDEX"] = Random().nextInt(gradients.length);

        // Create a UUID to reference this response.
        var uuidGenerator = const Uuid();
        var uuid = uuidGenerator.v4();
        jsonResponse["UUID"] = uuid.toString();

        // Get a reference to the phone's storage.
        final box = GetStorage();

        // Save a copy of this form on disk casted as a Map
        box.write(uuid.toString(), jsonResponse as Map<String, dynamic>);

        // Add a reference to this entry in a list of all forms.
        List<dynamic> savedForms = box.read("SAVED_FORMS") ?? [];
        savedForms.add(uuid.toString());
        box.write("SAVED_FORMS", savedForms);

        // Generate a [GeneratedForm] from the responses.
        var generatedForm = GeneratedForm.fromJson(jsonResponse);

        // Navigate to the [ViewForm] page.
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
