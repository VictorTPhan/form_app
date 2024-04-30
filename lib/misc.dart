import 'package:flutter/material.dart';

const String backendURL = "https://form-app-server-zibv.onrender.com";

void navigateTo(BuildContext context, StatefulWidget newScreen) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => newScreen,
    ),
  );
}

TextStyle standardTextStyle(
    {double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    Color color = Colors.black}
    ) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    color: color
  );
}

const gradients = [
  [Color(0xFFFFAA48), Color(0xFFFF0073)],
  [Color(0xFF00FF3A), Color(0xFF00796D)],
  [Color(0xFFFFC74B), Color(0xFF05A200)],
  [Color(0xFFFFF000), Color(0xFFF9035E)],
  [Color(0xFF00FF97), Color(0xFF0059FF)],
  [Color(0xFFE003F9), Color(0xFF2F00FF)],
  [Color(0xFF03AFF9), Color(0xFF0022FF)],
];

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
