import 'package:flutter/material.dart';
import 'package:form_app/create_form.dart';
import 'package:form_app/misc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                navigateTo(context, CreateForm());
              },
              child: Text("Create a Form")
          )
        ],
      ),
    );
  }
}
