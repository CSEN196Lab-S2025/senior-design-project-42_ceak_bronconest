import 'dart:convert';
import 'package:bronconest_app/models/review.dart';

class Dorm {
  final String id;
  final String name;
  final String locationAddress;
  final (double, double) locationLongLat;
  final String coverImage;
  final String shortDescription;
  final List<Review> reviews;

  Dorm({
    required this.id,
    required this.name,
    required this.locationAddress,
    required this.locationLongLat,
    required this.coverImage,
    required this.shortDescription,
    required this.reviews,
  });

  factory Dorm.fromJSON(Map<String, dynamic> json) => Dorm(
    id: json['id'].toString(),
    name: json['name'].toString(),
    locationAddress: json['address'].toString(),
    locationLongLat: (
      double.parse(json['long'].toString()),
      double.parse(json['lat'].toString()),
    ),
    coverImage: json['cover_image'].toString(),
    shortDescription: json['short_description'].toString(),
    reviews: [],
  );

  String toJsonString() => json.encode({
    'id': id,
    'name': name,
    'address': locationAddress,
    'long': locationLongLat.$1,
    'lat': locationLongLat.$2,
    'cover_image': coverImage,
    'short_description': shortDescription,
  });
}
