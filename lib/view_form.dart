import 'package:flutter/material.dart';
import 'package:form_app/generated_form.dart';

class ViewForm extends StatefulWidget {
  ViewForm({super.key, required this.generatedForm});

  GeneratedForm generatedForm;

  @override
  State<ViewForm> createState() => _ViewFormState();
}

class _ViewFormState extends State<ViewForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.generatedForm.name),
      ),
      body: ListView.builder(
        itemCount: widget.generatedForm.questions.length,
        itemBuilder: (BuildContext context, int index) {
          return widget.generatedForm.questions[index];
        },
      )
    );
  }
}
