import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/models/review.dart';
import 'package:bronconest_app/models/dorm.dart';
import 'package:bronconest_app/globals.dart';

class AddReviewPage extends StatefulWidget {
  final Dorm dorm;

  const AddReviewPage({super.key, required this.dorm});

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final TextEditingController _reviewContentController =
      TextEditingController();
  int? walkability;
  int? cleanliness;
  int? quietness;
  int? comfort;
  int? safety;
  int? amenities;
  int? community;
  bool isAnonymous = false;
  bool isLoading = false;

  @override
  void dispose() {
    _reviewContentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_reviewContentController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a review')));
      return;
    }

    if (walkability == null ||
        cleanliness == null ||
        quietness == null ||
        comfort == null ||
        safety == null ||
        amenities == null ||
        community == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please rate all categories')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final docRef =
          FirebaseFirestore.instance
              .collection('schools')
              .doc(school)
              .collection('dorms')
              .doc(widget.dorm.id)
              .collection('reviews')
              .doc();

      final review = Review(
        id: docRef.id,
        content: _reviewContentController.text,
        userId: userId,
        userName: userName,
        timestamp: DateTime.now(),
        walkability: walkability!,
        cleanliness: cleanliness!,
        quietness: quietness!,
        comfort: comfort!,
        safety: safety!,
        amenities: amenities!,
        community: community!,
        isAnonymous: isAnonymous,
      );

      await docRef.set(review.toJson());

      await _updateDormAvgs();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Review submitted')));

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting review: $e')));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateDormAvgs() async {
    try {
      final dormRef = FirebaseFirestore.instance
          .collection('schools')
          .doc(school)
          .collection('dorms')
          .doc(widget.dorm.id);

      final dormSnapshot = await dormRef.get();
      if (dormSnapshot.exists) {
        final dormData = dormSnapshot.data()!;
        final reviewsSnapshot = await dormRef.collection('reviews').get();
        final totalReviews = reviewsSnapshot.docs.length - 1;
        if (totalReviews == 0) {
          // If there are no reviews, set the averages to the current review values
          await dormRef.update({
            'walkability_avg': walkability,
            'cleanliness_avg': cleanliness,
            'quietness_avg': quietness,
            'comfort_avg': comfort,
            'safety_avg': safety,
            'amenities_avg': amenities,
            'community_avg': community,
          });
          return;
        }
        final newTotalReviews = totalReviews + 1;

        // Default averages to 0.0 if they don't exist
        final double walkabilityAvg =
            dormData['walkability_avg']?.toDouble() ?? 0.0;
        final double cleanlinessAvg =
            dormData['cleanliness_avg']?.toDouble() ?? 0.0;
        final double quietnessAvg =
            dormData['quietness_avg']?.toDouble() ?? 0.0;
        final double comfortAvg = dormData['comfort_avg']?.toDouble() ?? 0.0;
        final double safetyAvg = dormData['safety_avg']?.toDouble() ?? 0.0;
        final double amenitiesAvg =
            dormData['amenities_avg']?.toDouble() ?? 0.0;
        final double communityAvg =
            dormData['community_avg']?.toDouble() ?? 0.0;

        await dormRef.update({
          'walkability_avg':
              (walkabilityAvg * totalReviews + walkability!) / newTotalReviews,
          'cleanliness_avg':
              (cleanlinessAvg * totalReviews + cleanliness!) / newTotalReviews,
          'quietness_avg':
              (quietnessAvg * totalReviews + quietness!) / newTotalReviews,
          'comfort_avg':
              (comfortAvg * totalReviews + comfort!) / newTotalReviews,
          'safety_avg': (safetyAvg * totalReviews + safety!) / newTotalReviews,
          'amenities_avg':
              (amenitiesAvg * totalReviews + amenities!) / newTotalReviews,
          'community_avg':
              (communityAvg * totalReviews + community!) / newTotalReviews,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating dorm averages: $e')),
        );
      }
    }
  }

  Widget _buildRatingField(
    String label,
    String desc,
    int? value,
    Function(int?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(desc, style: const TextStyle(fontStyle: FontStyle.italic)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(10, (index) {
            final rating = index + 1;
            return Expanded(
              child: Column(
                children: [
                  Radio<int>(
                    value: rating,
                    groupValue: value,
                    onChanged: onChanged,
                  ),
                  Text(rating.toString(), style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 7.5,
            children: [
              const Text(
                'Please provide a review of your dorm experience.',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'You can include comments on the overall quality, amenities, and any suggestions for improvement.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              TextField(
                controller: _reviewContentController,
                decoration: const InputDecoration(
                  labelText: 'Review Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              _buildRatingField(
                'Walkability',
                'Consider factors such as nearby amenities and buildings and overall convenience.',
                walkability,
                (value) {
                  setState(() {
                    walkability = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildRatingField(
                'Cleanliness',
                'Consider the shared spaces, hallways, bathrooms, and common areas.',
                cleanliness,
                (value) {
                  setState(() {
                    cleanliness = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildRatingField(
                'Quietness',
                'Consider noise levels in the halls, study environments, and overall atmosphere.',
                quietness,
                (value) {
                  setState(() {
                    quietness = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildRatingField(
                'Comfort',
                'Consider aspects such as the furnishings, space, lighting, temperature control, and overall upkeep.',
                comfort,
                (value) {
                  setState(() {
                    comfort = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildRatingField(
                'Security & Safety',
                'Consider factors such as building security measures, lighting in common areas, and overall personal safety.',
                safety,
                (value) {
                  setState(() {
                    safety = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildRatingField(
                'Amenities',
                'Consider aspects such as the availability, condition, and accessibility of facilities like laundry rooms, study areas, recreational spaces, and common lounges.',
                amenities,
                (value) {
                  setState(() {
                    amenities = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildRatingField(
                'Community',
                'Consider factors such as the frequency of social events, the interaction among residents, opportunities to engage with peers, and the inclusiveness of dorm activities.',
                community,
                (value) {
                  setState(() {
                    community = value!;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Submit Anonymously'),
                value: isAnonymous,
                onChanged: (value) {
                  setState(() {
                    isAnonymous = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitReview,
                  child:
                      isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
