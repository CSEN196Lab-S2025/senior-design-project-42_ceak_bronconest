import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/models/review.dart';
import 'package:bronconest_app/globals.dart';

class EditReviewPage extends StatefulWidget {
  final Review review;
  final String dormId;
  final VoidCallback onReviewChanged;

  const EditReviewPage({
    super.key,
    required this.review,
    required this.dormId,
    required this.onReviewChanged,
  });

  @override
  State<EditReviewPage> createState() => _EditReviewPageState();
}

class _EditReviewPageState extends State<EditReviewPage> {
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
  void initState() {
    super.initState();
    _reviewContentController.text = widget.review.content;
    walkability = widget.review.walkability;
    cleanliness = widget.review.cleanliness;
    quietness = widget.review.quietness;
    comfort = widget.review.comfort;
    safety = widget.review.safety;
    amenities = widget.review.amenities;
    community = widget.review.community;
    isAnonymous = widget.review.isAnonymous;
  }

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
      final docRef = FirebaseFirestore.instance
          .collection('schools')
          .doc(school)
          .collection('dorms')
          .doc(widget.dormId)
          .collection('reviews')
          .doc(widget.review.id);

      final review = Review(
        id: docRef.id,
        content: _reviewContentController.text,
        userId: userId,
        walkability: walkability!,
        cleanliness: cleanliness!,
        quietness: quietness!,
        comfort: comfort!,
        safety: safety!,
        amenities: amenities!,
        community: community!,
        isAnonymous: isAnonymous,
      );

      await docRef.update(review.toJson());

      await _updateDormAvgs();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Review updated')));

        Navigator.of(context).pop();
        widget.onReviewChanged();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating review: $e')));
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
          .doc(widget.dormId);

      final dormSnapshot = await dormRef.get();
      if (dormSnapshot.exists) {
        final dormData = dormSnapshot.data()!;
        final reviewsSnapshot = await dormRef.collection('reviews').get();
        final totalReviews = reviewsSnapshot.docs.length;

        final double walkabilityAvg = dormData['walkability_avg']?.toDouble();
        final double cleanlinessAvg = dormData['cleanliness_avg']?.toDouble();
        final double quietnessAvg = dormData['quietness_avg']?.toDouble();
        final double comfortAvg = dormData['comfort_avg']?.toDouble();
        final double safetyAvg = dormData['safety_avg']?.toDouble();
        final double amenitiesAvg = dormData['amenities_avg']?.toDouble();
        final double communityAvg = dormData['community_avg']?.toDouble();

        // Calculate the difference between old and new values
        final double walkabilityDiff =
            walkability!.toDouble() - widget.review.walkability;
        final double cleanlinessDiff =
            cleanliness!.toDouble() - widget.review.cleanliness;
        final double quietnessDiff =
            quietness!.toDouble() - widget.review.quietness;
        final double comfortDiff = comfort!.toDouble() - widget.review.comfort;
        final double safetyDiff = safety!.toDouble() - widget.review.safety;
        final double amenitiesDiff =
            amenities!.toDouble() - widget.review.amenities;
        final double communityDiff =
            community!.toDouble() - widget.review.community;

        await dormRef.update({
          'walkability_avg': walkabilityAvg + (walkabilityDiff / totalReviews),
          'cleanliness_avg': cleanlinessAvg + (cleanlinessDiff / totalReviews),
          'quietness_avg': quietnessAvg + (quietnessDiff / totalReviews),
          'comfort_avg': comfortAvg + (comfortDiff / totalReviews),
          'safety_avg': safetyAvg + (safetyDiff / totalReviews),
          'amenities_avg': amenitiesAvg + (amenitiesDiff / totalReviews),
          'community_avg': communityAvg + (communityDiff / totalReviews),
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
              ElevatedButton(
                onPressed: isLoading ? null : _submitReview,
                child:
                    isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Update Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
