import 'dart:convert';

class Review {
  final String id;
  final String userId;
  final String content;
  final int walkability;
  final int cleanliness;
  final int quietness;
  final int comfort;
  final int safety;
  final int amenities;
  final int community;
  final bool isAnonymous;

  Review({
    required this.id,
    required this.userId,
    required this.content,
    required this.walkability,
    required this.cleanliness,
    required this.quietness,
    required this.comfort,
    required this.safety,
    required this.amenities,
    required this.community,
    this.isAnonymous = false,
  });

  factory Review.fromJSON(Map<String, dynamic> json) => Review(
    id: json['id'].toString(),
    userId: json['user_id'].toString(),
    content: json['content'].toString(),
    walkability: int.parse(json['walkability'].toString()),
    cleanliness: int.parse(json['cleanliness'].toString()),
    quietness: int.parse(json['quietness'].toString()),
    comfort: int.parse(json['comfort'].toString()),
    safety: int.parse(json['safety'].toString()),
    amenities: int.parse(json['amenities'].toString()),
    community: int.parse(json['community'].toString()),
    isAnonymous:
        json['is_anonymous'] != null ? json['is_anonymous'] as bool : false,
  );

  String toJsonString() => json.encode({
    'id': id,
    'user_id': userId,
    'content': content,
    'walkability': walkability,
    'cleanliness': cleanliness,
    'quietness': quietness,
    'comfort': comfort,
    'safety': safety,
    'amenities': amenities,
    'community': community,
    'is_anonymous': isAnonymous,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'walkability': walkability,
      'cleanliness': cleanliness,
      'quietness': quietness,
      'comfort': comfort,
      'safety': safety,
      'amenities': amenities,
      'community': community,
      'is_anonymous': isAnonymous,
    };
  }
}
