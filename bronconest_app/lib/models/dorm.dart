class Dorm {
  final String name;

  Dorm({required this.name});

  factory Dorm.fromJSON(Map<String, dynamic> json) {
    return Dorm(name: json['name'].toString());
  }
}
