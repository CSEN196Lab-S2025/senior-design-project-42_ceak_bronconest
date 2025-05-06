import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/models/house.dart';
import 'package:bronconest_app/widgets/house_card.dart';
import 'package:bronconest_app/globals.dart';

class ExploreHousesPage extends StatefulWidget {
  const ExploreHousesPage({super.key});

  @override
  State<ExploreHousesPage> createState() => _ExploreHousesPageState();
}

class _ExploreHousesPageState extends State<ExploreHousesPage> {
  List<House> houses = [];
  List<String> savedPlaceIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHouses();
  }

  Future<void> _fetchHouses() async {
    try {
      final housesSnapshot =
          await FirebaseFirestore.instance
              .collection('schools')
              .doc(school)
              .collection('houses')
              .get();
      final userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      setState(() {
        houses =
            housesSnapshot.docs
                .map((doc) => House.fromJSON(doc.data()))
                .toList();
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
        ).showSnackBar(SnackBar(content: Text('Error fetching houses: $e')));
      }
    }
  }

  Future<void> _toggleSavedPlace(House house) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    if (savedPlaceIds.contains(house.id)) {
      await userDoc.update({
        'savedPlaces': FieldValue.arrayRemove([house.id]),
      });
      setState(() {
        savedPlaceIds.remove(house.id);
      });
    } else {
      await userDoc.update({
        'savedPlaces': FieldValue.arrayUnion([house.id]),
      });
      setState(() {
        savedPlaceIds.add(house.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Houses')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: houses.length,
                itemBuilder: (context, index) {
                  final house = houses[index];
                  final isSaved = savedPlaceIds.contains(house.id);
                  return HouseCard(
                    house: house,
                    isSaved: isSaved,
                    toggleSavedPlace: _toggleSavedPlace,
                  );
                },
              ),
    );
  }
}
