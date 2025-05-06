import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/models/dorm.dart';
import 'package:bronconest_app/globals.dart';
import 'package:bronconest_app/widgets/dorm_card.dart';
import 'package:bronconest_app/pages/filter_page.dart';

class ExploreDormsPage extends StatefulWidget {
  const ExploreDormsPage({super.key});

  @override
  State<ExploreDormsPage> createState() => _ExploreDormsPageState();
}

class _ExploreDormsPageState extends State<ExploreDormsPage> {
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
                  return PlaceCard(
                    dorm: dorm,
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
