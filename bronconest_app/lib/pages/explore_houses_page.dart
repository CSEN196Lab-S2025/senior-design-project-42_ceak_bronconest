import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/models/house.dart';
import 'package:bronconest_app/widgets/house_card.dart';
import 'package:bronconest_app/pages/filter_houses_page.dart';
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

  Future<void> _fetchHouses({Map<String, dynamic>? filters}) async {
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

      List<House> filteredHouses =
          housesSnapshot.docs.map((doc) => House.fromJSON(doc.data())).toList();

      if (filters != null) {
        filteredHouses =
            filteredHouses.where((house) {
              final matchesPrice =
                  (filters['minPrice'] == null ||
                      (int.parse(
                            house.price
                                .replaceAll('+', '')
                                .replaceAll('\$', '')
                                .replaceAll(',', ''),
                          ) >=
                          filters['minPrice'])) &&
                  (filters['maxPrice'] == null ||
                      (int.parse(
                            house.price
                                .replaceAll('+', '')
                                .replaceAll('\$', '')
                                .replaceAll(',', ''),
                          ) <=
                          filters['maxPrice']));
              final matchesDistance =
                  filters['maxDistance'] == null ||
                  (house.distanceFromSchool != null &&
                      house.distanceFromSchool! <= filters['maxDistance']);
              final matchesBedrooms =
                  filters['minBedrooms'] == null ||
                  house.bedrooms >= filters['minBedrooms'];
              final matchesBathrooms =
                  filters['minBathrooms'] == null ||
                  (house.bathrooms != null &&
                      house.bathrooms! >= filters['minBathrooms']);
              return matchesPrice &&
                  matchesDistance &&
                  matchesBedrooms &&
                  matchesBathrooms;
            }).toList();
      }
      setState(() {
        houses = filteredHouses;
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

  Future<void> _navigateToFilterPage() async {
    final filters = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const FilterHousesPage()));

    if (filters != null && filters is Map<String, dynamic>) {
      setState(() {
        isLoading = true;
      });
      await _fetchHouses(filters: filters);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToFilterPage,
        child: const Icon(Icons.filter_list),
      ),
    );
  }
}
