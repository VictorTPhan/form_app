import 'package:flutter/material.dart';

abstract class Question {
  final String question;

  const Question({required this.question});

  dynamic toJson();
}
