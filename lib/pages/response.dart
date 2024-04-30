import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:form_app/forms/generated_response.dart';
import 'package:get_storage/get_storage.dart';

import '../misc.dart';

class ResponsePage extends StatefulWidget {
  ResponsePage({super.key, required this.responseUUID});

  String responseUUID;
  
  @override
  State<ResponsePage> createState() => _ResponsePageState();
}

class _ResponsePageState extends State<ResponsePage> {
  /// The [GeneratedResponse] to display on this page.
  late GeneratedResponse response;

  /// A reference to the [GetStorage] filesystem.
  late final GetStorage box;

  @override
  initState() {
    box = GetStorage();

    // Attempt to read from the box.
    final responseJSON = box.read(widget.responseUUID);

    // If we can't find it, tell the user that it's a dead link.
    if (responseJSON == null) {
      response = GeneratedResponse(
        name: "Sorry!",
        emoji: "X",
        body: "We couldn't fetch this response. Try creating another one."
      );
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
      body: FadeInDown(
        delay: const Duration(milliseconds: 150),
        child: Markdown(
          data: response.body,
        ),
      ),
    );
  }
}
