import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/pages/edit_review_page.dart';
import 'package:bronconest_app/models/review.dart';
import 'package:bronconest_app/globals.dart';

class ReviewTile extends StatefulWidget {
  final Review review;
  final String dormId;
  final VoidCallback onReviewChanged;

  const ReviewTile({
    super.key,
    required this.review,
    required this.dormId,
    required this.onReviewChanged,
  });

  @override
  State<ReviewTile> createState() => _ReviewTileState();
}

class _ReviewTileState extends State<ReviewTile> {
  bool showFullContent = false;

  void _deleteReview() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Review'),
          content: const Text('Are you sure you want to delete this review?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performDelete();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDelete() async {
    try {
      await _updateDormAvgs();

      await FirebaseFirestore.instance
          .collection('schools')
          .doc(school)
          .collection('dorms')
          .doc(widget.dormId)
          .collection('reviews')
          .doc(widget.review.id)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dorm deleted')));

      widget.onReviewChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting dorm: $e')));
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

        if (totalReviews > 1) {
          // Calculate new averages after removing the review
          final double walkabilityAvg = dormData['walkability_avg']?.toDouble();
          final double cleanlinessAvg = dormData['cleanliness_avg']?.toDouble();
          final double quietnessAvg = dormData['quietness_avg']?.toDouble();
          final double comfortAvg = dormData['comfort_avg']?.toDouble();
          final double safetyAvg = dormData['safety_avg']?.toDouble();
          final double amenitiesAvg = dormData['amenities_avg']?.toDouble();
          final double communityAvg = dormData['community_avg']?.toDouble();

          await dormRef.update({
            'walkability_avg':
                (walkabilityAvg * totalReviews - widget.review.walkability) /
                (totalReviews - 1),
            'cleanliness_avg':
                (cleanlinessAvg * totalReviews - widget.review.cleanliness) /
                (totalReviews - 1),
            'quietness_avg':
                (quietnessAvg * totalReviews - widget.review.quietness) /
                (totalReviews - 1),
            'comfort_avg':
                (comfortAvg * totalReviews - widget.review.comfort) /
                (totalReviews - 1),
            'safety_avg':
                (safetyAvg * totalReviews - widget.review.safety) /
                (totalReviews - 1),
            'amenities_avg':
                (amenitiesAvg * totalReviews - widget.review.amenities) /
                (totalReviews - 1),
            'community_avg':
                (communityAvg * totalReviews - widget.review.community) /
                (totalReviews - 1),
          });
        } else {
          // If this is the last review, reset averages to 0
          await dormRef.update({
            'walkability_avg': 0,
            'cleanliness_avg': 0,
            'quietness_avg': 0,
            'comfort_avg': 0,
            'safety_avg': 0,
            'amenities_avg': 0,
            'community_avg': 0,
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating dorm averages: $e')),
        );
      }
    }
  }

  String formatDate(DateTime date) {
    final day = date.day;
    final suffix =
        (day % 10 == 1 && day != 11)
            ? 'st'
            : (day % 10 == 2 && day != 12)
            ? 'nd'
            : (day % 10 == 3 && day != 13)
            ? 'rd'
            : 'th';
    return '${DateFormat('MMM').format(date)} $day$suffix, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool canEdit = widget.review.userId == userId;
    final bool canDelete = widget.review.userId == userId || isAdmin;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(
          'User: ${widget.review.isAnonymous ? 'Anonymous' : widget.review.userName}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatDate(widget.review.timestamp)),
            Text(
              widget.review.content,
              maxLines: showFullContent ? null : 3,
              overflow:
                  showFullContent
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
            ),
            if (widget.review.content.length > 100)
              GestureDetector(
                onTap: () {
                  setState(() {
                    showFullContent = !showFullContent;
                  });
                },
                child: Text(
                  showFullContent ? 'Show less' : 'Show more...',
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
              ),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,

                children: [
                  Text('Walkability: ${widget.review.walkability}'),
                  Text('Cleanliness: ${widget.review.cleanliness}'),
                  Text('Quietness: ${widget.review.quietness}'),
                  Text('Comfort: ${widget.review.comfort}'),
                  Text('Safety: ${widget.review.safety}'),
                  Text('Amenities: ${widget.review.amenities}'),
                  Text('Community: ${widget.review.community}'),
                ],
              ),
            ),
          ],
        ),
        showTrailingIcon: canEdit || canDelete,
        children: [
          if (canEdit)
            ListTile(
              title: const Text('Edit'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditReviewPage(
                          review: widget.review,
                          dormId: widget.dormId,
                          onReviewChanged: widget.onReviewChanged,
                        ),
                  ),
                );
              },
            ),
          if (canDelete)
            ListTile(
              title: const Text('Delete'),
              onTap: () {
                _deleteReview();
              },
            ),
        ],
      ),
    );
  }
}
