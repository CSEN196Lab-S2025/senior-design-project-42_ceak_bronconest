import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/models/review.dart';
import 'package:bronconest_app/models/dorm.dart';
import 'package:bronconest_app/widgets/review_card.dart';
import 'package:bronconest_app/globals.dart';

class DormReviewsPage extends StatefulWidget {
  final Dorm dorm;

  const DormReviewsPage({super.key, required this.dorm});

  @override
  State<DormReviewsPage> createState() => _DormReviewsPageState();
}

class _DormReviewsPageState extends State<DormReviewsPage> {
  List<Review> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final reviewsSnapshot =
          await FirebaseFirestore.instance
              .collection('schools')
              .doc(school)
              .collection('dorms')
              .doc(widget.dorm.id)
              .collection('reviews')
              .get();

      setState(() {
        reviews =
            reviewsSnapshot.docs
                .map((doc) => Review.fromJSON(doc.data()))
                .toList();
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching reviews: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.dorm.name} Reviews')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : reviews.isEmpty
              ? const Center(child: Text('No reviews yet'))
              : ListView.builder(
                itemBuilder: (context, index) {
                  return ReviewTile(review: reviews[index]);
                },
                itemCount: reviews.length,
              ),
    );
  }
}
