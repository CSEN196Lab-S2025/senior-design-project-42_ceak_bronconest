import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bronconest_app/models/dorm.dart';

String apiUrl = '';

/// Returns a [Map] of each school ID as a [String] mapped to a [List] of
/// [Dorm]s at that school.
Future<Map<String, List<Dorm>>> getAllDorms() async {
  String endpoint = '/get_all_dorms';
  var response = await http.Client().get(Uri.parse('$apiUrl$endpoint'));

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);
    Map<String, List<Dorm>> allDorms = {};

    json.forEach(
      (String schoolID, dynamic dorms) =>
          allDorms[schoolID] = dorms.map((dorm) => Dorm.fromJSON(dorm)),
    );

    return allDorms;
  } else {
    throw Exception('Error, code ${response.statusCode}');
  }
}

/// Returns a[List] of [Dorm]s from a specified [String] [schoolID].
Future<List<Dorm>> getDorms(String schoolID) async {
  String endpoint = '/get_dorms';
  var response = await http.Client().get(
    Uri.parse('$apiUrl$endpoint?school_id=$schoolID'),
  );

  if (response.statusCode == 200) {
    List<dynamic> json = jsonDecode(response.body);

    return json.map((dorm) => Dorm.fromJSON(dorm)).toList();
  } else {
    throw Exception('Error, code ${response.statusCode}');
  }
}

/// Returns a [Dorm] from a specified [String] [schoolID] and [String] [dormID].
Future<Dorm> getDorm(String schoolID, String dormID) async {
  String endpoint = '/get_dorm';
  var response = await http.Client().get(
    Uri.parse('$apiUrl$endpoint?school_id=$schoolID&dorm_id=$dormID'),
  );

  if (response.statusCode == 200) {
    dynamic json = jsonDecode(response.body);

    return Dorm.fromJSON(json);
  } else {
    throw Exception('Error, code ${response.statusCode}');
  }
}

/// Uploads a [dorm] of type [Dorm] to firebase. Returns a [bool] if successful.
Future<bool> createDorm(Dorm dorm) async {
  String endpoint = '/create_dorm';
  var response = await http.Client().post(
    Uri.parse('$apiUrl$endpoint'),
    body: {}, // TODO: add payload
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Error, code ${response.statusCode}');
  }
}
