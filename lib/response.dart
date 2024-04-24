import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:form_app/generated_response.dart';
import 'package:get_storage/get_storage.dart';

import 'misc.dart';

class ResponsePage extends StatefulWidget {
  ResponsePage({super.key, required this.responseUUID});

  String responseUUID;
  
  @override
  State<ResponsePage> createState() => _ResponsePageState();
}

class _ResponsePageState extends State<ResponsePage> {
  late GeneratedResponse response;
  late final box;

  @override
  initState() {
    box = GetStorage();

    final responseJSON = box.read(widget.responseUUID);
    if (responseJSON == null) {
      response = GeneratedResponse(name: "ERROR", emoji: "X", body: "NO RESPONSE");
    } else {
      response = GeneratedResponse.fromJson(responseJSON);
      response.body = response.body.replaceAll("\\n", "\n");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
            style: standardTextStyle(fontSize: 25),
            response.name
        ),
      ),
      body: Markdown(
        data: response.body,
      ),
    );
  }
}
