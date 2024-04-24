import 'package:flutter/cupertino.dart';
import 'package:form_app/questions/checkbox_question.dart';
import 'package:form_app/questions/long_answer_question.dart';
import 'package:form_app/questions/multiple_choice_question.dart';
import 'package:form_app/questions/question.dart';
import 'package:form_app/questions/short_answer_question.dart';

class GeneratedResponse {
  late String name;
  late String emoji;
  late String body;

  GeneratedResponse({
    required this.name,
    required this.emoji,
    required this.body
  });

  GeneratedResponse.fromJson(Map<String, dynamic> json) {
    emoji = json["EMOJI"];
    name = json['NAME'];
    body = json["RESPONSE"];
  }

  dynamic toJson() {
    return {
      "EMOJI": name,
      "NAME": emoji,
      "RESPONSE": body,
    };
  }
}