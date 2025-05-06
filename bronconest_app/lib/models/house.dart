import 'dart:convert';

class House {
  final String id;
  final String address;
  final String price;
  final String type;
  final int bedrooms;
  final int? bathrooms;
  final int? sqft;
  final String image;
  final String listing;
  final double? distanceFromSchool;
  String? schoolId;

  House({
    required this.id,
    required this.address,
    required this.price,
    required this.type,
    required this.bedrooms,
    this.bathrooms,
    this.sqft,
    required this.image,
    required this.listing,
    this.distanceFromSchool,
    this.schoolId,
  });

  factory House.fromJSON(Map<String, dynamic> json) => House(
    id: json['id'].toString(),
    address: json['address'].toString(),
    price: json['price'].toString(),
    type: json['type'].toString(),
    bedrooms: json['bedrooms'] as int,
    bathrooms:
        json['bathrooms'] != null
            ? int.parse(json['bathrooms'].toString())
            : null,
    sqft: json['sqft'] != null ? int.parse(json['sqft'].toString()) : null,
    image: json['image'].toString(),
    listing: json['listing'].toString(),
    distanceFromSchool:
        json['distance_from_school'] != null
            ? double.parse(json['distance_from_school'].toString())
            : null,
  );

  String toJsonString() => json.encode({
    'id': id,
    'address': address,
    'price': price,
    'type': type,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'sqft': sqft,
    'image': image,
    'listing': listing,
    'distanceFromSchool': distanceFromSchool,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'price': price,
      'type': type,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'sqft': sqft,
      'image': image,
      'listing': listing,
      'distanceFromSchool': distanceFromSchool,
    };
  }
}
