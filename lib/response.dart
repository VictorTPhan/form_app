import 'package:flutter/material.dart';

class ResponsePage extends StatefulWidget {
  ResponsePage({super.key, required this.response});

  String response;
  
  @override
  State<ResponsePage> createState() => _ResponsePageState();
}

class _ResponsePageState extends State<ResponsePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Here You Go!"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.response.replaceAll("\\n", "\n").substring(1, widget.response.replaceAll("\\n", "\n").length-2)),
          )
        ],
      ),
    );
  }
}
