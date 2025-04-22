import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          savedPlaces = await Future.wait(
            savedPlacesList.map((dormId) async {
              final dormSnapshot =
                  await FirebaseFirestore.instance
                      .collection('schools')
                      .doc(school)
                      .collection('dorms')
                      .doc(dormId)
                      .get();
              return Dorm.fromJSON(dormSnapshot.data()!);
            }),
          );
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
              ? const Center(child: Text('No saved places'))
              : ListView.builder(
                itemCount: savedPlaces.length,
                itemBuilder: (context, index) {
                  final dorm = savedPlaces[index];
                  return ListTile(
                    leading: Icon(Icons.favorite),
                    title: Text(dorm.name),
                    subtitle: Text(dorm.shortDescription),
                    onTap: () {
                      // Navigate to dorm details page
                    },
                  );
                },
              ),
    );
  }
}
