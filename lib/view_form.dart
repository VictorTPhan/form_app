import 'dart:collection';
import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
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
import 'misc.dart';

class ViewForm extends StatefulWidget {
  ViewForm({super.key, required this.generatedForm});

  GeneratedForm generatedForm;

  @override
  State<ViewForm> createState() => _ViewFormState();
}

class _ViewFormState extends State<ViewForm> {
  /// The [GlobalKey] used by the form on this screen to validate the form.
  final formKey = GlobalKey<FormState>();

  /// A boolean representing if the form on this screen is validated.
  bool formValidated = false;

  /// A [String] representation of the JSON of this form.
  String currentFormResponseString = "";

  /// The amount of milliseconds to increase the delay by every time a widget
  /// is loaded.
  int delayIncrease = 200;

  /// The amount of milliseconds to delay a widget by when it loads.
  late int delay = -delayIncrease;

  /// Determines if the form on this page is filled in properly.
  bool isFormValidated(UnmodifiableMapView<String, dynamic> responses) {
    // Look through every question.
    for (String question in responses.keys) {
      var response = responses[question];

      // Generally, just check if the question is filled in
      if (response is String && response.isEmpty ||
          response is Set && response.isEmpty) {
        return false;
      }
    }
    return true;
  }

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

  /// Parses a [Question] object by its [index] within the questions list in the
  /// [generatedForm] and builds a [Widget] to display it.
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
              title: Text(
                style: standardTextStyle(),
                option
              ),
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

    delay += delayIncrease;

    return createWidgetWithDelay(
      createFormQuestion(
        currentQuestion.question,
        inputWidget
      )
    );
  }

  /// Sends a POST request to the Formerly server to generate a form response.
  Future<void> sendPostRequest() async {
    var url = Uri.parse('https://form-app-server-zibv.onrender.com/submit_form/');

    // Create the payload.
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

        // Get a reference to the phone's storage.
        final box = GetStorage();

        // Create a UUID to reference this response.
        var uuidGenerator = const Uuid();
        var responseUUID = uuidGenerator.v4();

        // Save the response into the phone's storage.
        box.write(responseUUID.toString(), jsonResponse);

        // Add this response UUID to a list of all responses.
        String address = "${widget.generatedForm.uuid}/responses";
        List<dynamic> formResponses = box.read(address) ?? [];
        formResponses.add(responseUUID.toString());
        box.write(address, formResponses);

        // View the response.
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      sendPostRequest();
                    },
                    child: Text("Let's Go")
                  ),
                )
            ]
          ),
        ),
      )
    );
  }
}
