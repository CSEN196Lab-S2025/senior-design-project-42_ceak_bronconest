import 'dart:convert';

class Dorm {
  final String id;
  final String name;

  Dorm({required this.id, required this.name});

  factory Dorm.fromJSON(Map<String, dynamic> json) =>
      Dorm(id: json['id'].toString(), name: json['name'].toString());

  String toJsonString() => json.encode({'id': id, 'name': name});
}
