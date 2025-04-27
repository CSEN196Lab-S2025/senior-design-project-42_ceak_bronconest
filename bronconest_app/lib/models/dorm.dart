import 'dart:convert';
import 'package:bronconest_app/models/review.dart';

class Dorm {
  final String id;
  final String name;
  final String locationAddress;
  final (double, double) locationLongLat;
  final String coverImage;
  final String shortDescription;
  final double walkabilityAvg;
  final double cleanlinessAvg;
  final double quietnessAvg;
  final double comfortAvg;
  final double safetyAvg;
  final double amenitiesAvg;
  final double communityAvg;
  final List<Review> reviews;

  Dorm({
    required this.id,
    required this.name,
    required this.locationAddress,
    required this.locationLongLat,
    required this.coverImage,
    required this.shortDescription,
    required this.walkabilityAvg,
    required this.cleanlinessAvg,
    required this.quietnessAvg,
    required this.comfortAvg,
    required this.safetyAvg,
    required this.amenitiesAvg,
    required this.communityAvg,
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
    walkabilityAvg: double.parse(json['walkability_avg'].toString()),
    cleanlinessAvg: double.parse(json['cleanliness_avg'].toString()),
    quietnessAvg: double.parse(json['quietness_avg'].toString()),
    comfortAvg: double.parse(json['comfort_avg'].toString()),
    safetyAvg: double.parse(json['safety_avg'].toString()),
    amenitiesAvg: double.parse(json['amenities_avg'].toString()),
    communityAvg: double.parse(json['community_avg'].toString()),
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
    'walkability_avg': walkabilityAvg,
    'cleanliness_avg': cleanlinessAvg,
    'quietness_avg': quietnessAvg,
    'comfort_avg': comfortAvg,
    'safety_avg': safetyAvg,
    'amenities_avg': amenitiesAvg,
    'community_avg': communityAvg,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': locationAddress,
      'long': locationLongLat.$1,
      'lat': locationLongLat.$2,
      'cover_image': coverImage,
      'short_description': shortDescription,
      'walkability_avg': walkabilityAvg,
      'cleanliness_avg': cleanlinessAvg,
      'quietness_avg': quietnessAvg,
      'comfort_avg': comfortAvg,
      'safety_avg': safetyAvg,
      'amenities_avg': amenitiesAvg,
      'community_avg': communityAvg,
    };
  }
}
