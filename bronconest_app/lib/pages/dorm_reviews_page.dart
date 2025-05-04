import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bronconest_app/models/review.dart';
import 'package:bronconest_app/models/dorm.dart';
import 'package:bronconest_app/widgets/review_card.dart';
import 'package:bronconest_app/widgets/image_gradient_overlay.dart';
import 'package:bronconest_app/globals.dart';
import 'package:bronconest_app/pages/add_review_page.dart';
import 'package:bronconest_app/styles.dart';

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(24.0),
                  bottomLeft: Radius.circular(24.0),
                ),
                child: SizedBox(
                  height: 250,
                  child: CachedNetworkImage(
                    imageUrl: widget.dorm.coverImage,
                    fit: BoxFit.cover,
                    width: 2000, // lol this makes the cover fit the width
                    placeholder:
                        (context, url) => Center(
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              ImageGradientOverlay(),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.dorm.name, style: Styles.largeTextStyle),
          ),
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.dorm.shortDescription,
                        style: Styles.smallTextStyle,
                      ),
                      // Reviews:
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Overall Scores',
                          style: Styles.mediumTextStyle,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Wrap(
                        children:
                            widget.dorm.ratingScores
                                .map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(e.icon),
                                            Text(
                                              ' ${e.name} ${e.scoreString}',
                                              style: Styles.smallTextStyle,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'User Reviews',
                          style: Styles.mediumTextStyle,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
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
                                              (context) => AddReviewPage(
                                                dorm: widget.dorm,
                                              ),
                                        ),
                                      ).then((_) => _fetchReviews());
                                    },
                                  ),
                                ),
                              if (reviews.isEmpty)
                                const Expanded(
                                  child: Center(child: Text('No reviews yet')),
                                )
                              else
                                ...reviews.map(
                                  (review) => ReviewTile(
                                    review: review,
                                    dormId: widget.dorm.id,
                                    onReviewChanged: _fetchReviews,
                                  ),
                                ),
                            ],
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
