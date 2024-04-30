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