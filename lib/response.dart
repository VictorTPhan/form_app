import 'package:animate_do/animate_do.dart';
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
  /// The [GeneratedResponse] to display on this page.
  late GeneratedResponse response;

  /// A reference to the phone's storage.
  late final box;

  @override
  initState() {
    // Grab a reference to this phone's storage.
    box = GetStorage();

    // Attempt to read the response UUID.
    final responseJSON = box.read(widget.responseUUID);

    // If there's no response, show dummy text.
    if (responseJSON == null) {
      response = GeneratedResponse(name: "ERROR", emoji: "X", body: "NO RESPONSE");
    } else {
      response = GeneratedResponse.fromJson(responseJSON);

      // Remove anything that would mess with markdown formatting.
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
      body: FadeInDown(
        delay: const Duration(milliseconds: 150),
        child: Markdown(
          data: response.body,
        ),
      ),
    );
  }
}
