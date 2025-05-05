import 'package:bronconest_app/widgets/place_card.dart';
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

  Future<void> _toggleSavedPlace(Dorm dorm) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    await userDoc.update({
      'savedPlaces': FieldValue.arrayRemove([dorm.id]),
    });

    setState(() {
      savedPlaces.remove(dorm);
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
                  final dorm = savedPlaces[index];
                  return PlaceCard(
                    dorm: dorm,
                    isSaved: true,
                    toggleSavedPlace: _toggleSavedPlace,
                    showScoreRow: false,
                    schoolId: dorm.schoolId,
                    // onTap: () {
                    //   Navigator.of(context).push(
                    //     MaterialPageRoute(
                    //       builder: (context) => DormChatPage(dormId: dorm.id),
                    //       ),
                    //     ),
                    //   );
                    // },
                  );
                },
              ),
    );
  }
}

// import 'package:firebase_messaging/firebase_messaging.dart';

// @override
// void initState() {
//   super.initState();
//   FirebaseMessaging.instance.subscribeToTopic('dorm_${widget.dormId}_chat');
// }

// @override
// void dispose() {
//   FirebaseMessaging.instance.unsubscribeFromTopic('dorm_${widget.dormId}_chat');
//   super.dispose();
// }
