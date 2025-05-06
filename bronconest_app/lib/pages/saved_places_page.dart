import 'package:bronconest_app/widgets/dorm_card.dart';
import 'package:bronconest_app/widgets/house_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/models/dorm.dart';
import 'package:bronconest_app/models/house.dart';
import 'package:bronconest_app/globals.dart';

class SavedPlacesPage extends StatefulWidget {
  const SavedPlacesPage({super.key});

  @override
  State<SavedPlacesPage> createState() => _SavedPlacesPageState();
}

class _SavedPlacesPageState extends State<SavedPlacesPage> {
  List<dynamic> savedPlaces = [];
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
            savedPlacesList.map((placeId) async {
              dynamic foundPlace;
              for (final schoolDoc in schoolSnapshot.docs) {
                final dormSnapshot =
                    await FirebaseFirestore.instance
                        .collection('schools')
                        .doc(schoolDoc.id)
                        .collection('dorms')
                        .doc(placeId)
                        .get();

                if (dormSnapshot.exists) {
                  final dorm = Dorm.fromJSON(dormSnapshot.data()!);
                  dorm.schoolId = schoolDoc.id;
                  foundPlace = dorm;
                  break;
                }

                final houseSnapshot =
                    await FirebaseFirestore.instance
                        .collection('schools')
                        .doc(schoolDoc.id)
                        .collection('houses')
                        .doc(placeId)
                        .get();

                if (houseSnapshot.exists) {
                  final house = House.fromJSON(houseSnapshot.data()!);
                  house.schoolId = schoolDoc.id;
                  foundPlace = house;
                  break;
                }
              }
              if (foundPlace == null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No saved places found')),
                );
              }

              return foundPlace;
            }),
          ).then((places) => places.where((place) => place != null).toList());
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

  Future<void> _toggleSavedPlace(dynamic place) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    await userDoc.update({
      'savedPlaces': FieldValue.arrayRemove([place.id]),
    });

    setState(() {
      savedPlaces.remove(place);
    });
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
                  final place = savedPlaces[index];
                  if (place is Dorm) {
                    return PlaceCard(
                      dorm: place,
                      isSaved: true,
                      toggleSavedPlace: _toggleSavedPlace,
                      showScoreRow: false,
                      schoolId: place.schoolId,
                      runOnPop: _fetchSavedPlaces,
                    );
                  } else if (place is House) {
                    return HouseCard(
                      house: place,
                      isSaved: true,
                      toggleSavedPlace: _toggleSavedPlace,
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
    );
  }
}
