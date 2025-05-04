import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/pages/dorm_reviews_page.dart';
import 'package:bronconest_app/models/dorm.dart';
import 'package:bronconest_app/globals.dart';

class SavedPlacesPage extends StatefulWidget {
  const SavedPlacesPage({super.key});

  @override
  State<SavedPlacesPage> createState() => _SavedPlacesPageState();
}

class _SavedPlacesPageState extends State<SavedPlacesPage> {
  List<Dorm> savedPlaces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSavedPlaces();
  }

  Future<void> _fetchSavedPlaces() async {
    try {
      final userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (userSnapshot.exists) {
        final savedPlacesList =
            userSnapshot.data()?['savedPlaces'] as List<dynamic>;

        if (savedPlacesList.isEmpty) {
          savedPlaces = [];
        } else {
          final schoolSnapshot =
              await FirebaseFirestore.instance.collection('schools').get();

          savedPlaces = await Future.wait(
            savedPlacesList.map((dormId) async {
              for (final schoolDoc in schoolSnapshot.docs) {
                final dormSnapshot =
                    await FirebaseFirestore.instance
                        .collection('schools')
                        .doc(schoolDoc.id)
                        .collection('dorms')
                        .doc(dormId)
                        .get();

                if (dormSnapshot.exists) {
                  final dorm = Dorm.fromJSON(dormSnapshot.data()!);
                  dorm.schoolId = schoolDoc.id;
                  return dorm;
                }
              }
              return null;
            }),
          ).then((dorms) => dorms.whereType<Dorm>().toList());
        }
      } else {
        savedPlaces = [];
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching saved places: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Saved Places Page'),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : savedPlaces.isEmpty
              ? const Center(
                child: Text(
                  'Save your favorite places \non the explore page',
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.builder(
                itemCount: savedPlaces.length,
                itemBuilder: (context, index) {
                  final dorm = savedPlaces[index];
                  return ListTile(
                    leading: Icon(Icons.favorite),
                    title: Text(dorm.name),
                    subtitle: Text(dorm.shortDescription),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DormReviewsPage(
                                dorm: dorm,
                                schoolId: dorm.schoolId,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
