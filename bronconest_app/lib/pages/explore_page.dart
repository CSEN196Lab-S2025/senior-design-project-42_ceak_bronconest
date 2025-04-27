import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/models/dorm.dart';
import 'package:bronconest_app/globals.dart';
import 'package:bronconest_app/pages/dorm_reviews_page.dart';
import 'package:bronconest_app/pages/filter_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<Dorm> dorms = [];
  List<String> savedPlaceIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDorms();
  }

  Future<void> _fetchDorms() async {
    try {
      final dormsSnapshot =
          await FirebaseFirestore.instance
              .collection('schools')
              .doc(school)
              .collection('dorms')
              .get();
      final userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      setState(() {
        dorms =
            dormsSnapshot.docs.map((doc) => Dorm.fromJSON(doc.data())).toList();
        savedPlaceIds =
            userSnapshot.data()?['savedPlaces'] != null
                ? List<String>.from(userSnapshot.data()!['savedPlaces'])
                : [];
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching dorms: $e')));
      }
    }
  }

  Future<void> _toggleSavedPlace(Dorm dorm) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    if (savedPlaceIds.contains(dorm.id)) {
      await userDoc.update({
        'savedPlaces': FieldValue.arrayRemove([dorm.id]),
      });
      setState(() {
        savedPlaceIds.remove(dorm.id);
      });
    } else {
      await userDoc.update({
        'savedPlaces': FieldValue.arrayUnion([dorm.id]),
      });
      setState(() {
        savedPlaceIds.add(dorm.id);
      });
    }
  }

  Future<void> _navigateToFilterPage() async {
    final sortedIds = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const FilterPage()));

    if (sortedIds != null) {
      setState(() {
        dorms.sort((a, b) {
          final indexA = sortedIds.indexOf(a.id);
          final indexB = sortedIds.indexOf(b.id);
          return indexA.compareTo(indexB);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Explore Dorms'),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: dorms.length,
                itemBuilder: (context, index) {
                  final dorm = dorms[index];
                  final isSaved = savedPlaceIds.contains(dorm.id);
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DormReviewsPage(dorm: dorm),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Image.network(
                          dorm.coverImage,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(dorm.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dorm.shortDescription),
                            Text(
                              'Walkability: ${dorm.walkabilityAvg.toStringAsFixed(1)}',
                            ),
                            Text(
                              'Cleanliness: ${dorm.cleanlinessAvg.toStringAsFixed(1)}',
                            ),
                            Text(
                              'Quietness: ${dorm.quietnessAvg.toStringAsFixed(1)}',
                            ),
                            Text(
                              'Comfort: ${dorm.comfortAvg.toStringAsFixed(1)}',
                            ),
                            Text(
                              'Safety: ${dorm.safetyAvg.toStringAsFixed(1)}',
                            ),
                            Text(
                              'Amenities: ${dorm.amenitiesAvg.toStringAsFixed(1)}',
                            ),
                            Text(
                              'Community: ${dorm.communityAvg.toStringAsFixed(1)}',
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                          ),
                          onPressed: () {
                            _toggleSavedPlace(dorm);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToFilterPage,
        child: const Icon(Icons.filter_list),
      ),
    );
  }
}
