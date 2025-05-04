import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/models/review.dart';
import 'package:bronconest_app/models/dorm.dart';
import 'package:bronconest_app/widgets/review_card.dart';
import 'package:bronconest_app/globals.dart';
import 'package:bronconest_app/pages/add_review_page.dart';

class DormReviewsPage extends StatefulWidget {
  final Dorm dorm;
  final String? schoolId;

  const DormReviewsPage({super.key, required this.dorm, this.schoolId});

  @override
  State<DormReviewsPage> createState() => _DormReviewsPageState();
}

class _DormReviewsPageState extends State<DormReviewsPage> {
  List<Review> reviews = [];
  bool isLoading = true;
  String schoolId = '';

  @override
  void initState() {
    super.initState();
    schoolId = widget.schoolId ?? school;
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final reviewsSnapshot =
          await FirebaseFirestore.instance
              .collection('schools')
              .doc(schoolId)
              .collection('dorms')
              .doc(widget.dorm.id)
              .collection('reviews')
              .get();

      setState(() {
        reviews =
            reviewsSnapshot.docs
                .map((doc) => Review.fromJSON(doc.data()))
                .toList();
        reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
              ? Column(
                children: [
                  if (isStudent)
                    Card(
                      margin: const EdgeInsets.all(16.0),
                      child: ListTile(
                        leading: const Icon(Icons.add),
                        title: const Text('Add a Review'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AddReviewPage(dorm: widget.dorm),
                            ),
                          ).then((_) => _fetchReviews());
                        },
                      ),
                    ),
                  const Expanded(child: Center(child: Text('No reviews yet'))),
                ],
              )
              : ListView.builder(
                itemCount: reviews.length + (isStudent ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isStudent && index == 0) {
                    return Card(
                      margin: const EdgeInsets.all(16.0),
                      child: ListTile(
                        leading: const Icon(Icons.add),
                        title: const Text('Add a Review'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AddReviewPage(dorm: widget.dorm),
                            ),
                          ).then((_) => _fetchReviews());
                        },
                      ),
                    );
                  }
                  return ReviewTile(
                    review: reviews[isStudent ? index - 1 : index],
                    dormId: widget.dorm.id,
                    onReviewChanged: _fetchReviews,
                  );
                },
              ),
    );
  }
}
