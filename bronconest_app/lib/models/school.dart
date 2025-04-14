import 'dart:convert';
import 'package:bronconest_app/models/dorm.dart';

class School {
  final String id;
  final String name;
  final String address;
  final List<Dorm> dorms;

  School({
    required this.id,
    required this.name,
    required this.address,
    required this.dorms,
  });

  factory School.fromJSON(Map<String, dynamic> json) => School(
    id: json['id'].toString(),
    name: json['name'].toString(),
    address: json['address'].toString(),
    dorms:
        (json['dorms'] as List<dynamic>).map((e) => Dorm.fromJSON(e)).toList(),
  );

  String toJsonString() => json.encode({
    'id': id,
    'name': name,
    'address': address,
    'dorms': dorms.map((dorm) => dorm.toJsonString()).toList(),
  });
}
