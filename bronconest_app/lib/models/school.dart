import 'package:bronconest_app/models/dorm.dart';

class School {
  final String name;
  final String address;
  final List<Dorm> dorms;

  School({required this.name, required this.address, required this.dorms});

  factory School.fromJSON(Map<String, dynamic> json) {
    return School(
      name: json['name'].toString(),
      address: json['address'].toString(),
      dorms:
          (json['dorms'] as List<dynamic>)
              .map((e) => Dorm.fromJSON(e))
              .toList(),
    );
  }
}
