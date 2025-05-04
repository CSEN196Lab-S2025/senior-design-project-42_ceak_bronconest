import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/pages/add_dorm_page.dart';
import 'package:bronconest_app/pages/edit_dorm_page.dart';
import 'package:bronconest_app/widgets/admin_card.dart';
import 'package:bronconest_app/models/dorm.dart';
import 'package:bronconest_app/globals.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool isLoading = true;
  List<Dorm> dorms = [];

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

      setState(() {
        dorms =
            dormsSnapshot.docs.map((doc) => Dorm.fromJSON(doc.data())).toList();
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

  void _deleteDorm(String dormId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Dorm'),
          content: const Text('Are you sure you want to delete this dorm?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performDelete(dormId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDelete(String dormId) async {
    try {
      final reviews =
          await FirebaseFirestore.instance
              .collection('schools')
              .doc(school)
              .collection('dorms')
              .doc(dormId)
              .collection('reviews')
              .get();

      for (final reviewDoc in reviews.docs) {
        await reviewDoc.reference.delete();
      }

      await FirebaseFirestore.instance
          .collection('schools')
          .doc(school)
          .collection('dorms')
          .doc(dormId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dorm deleted')));

      _fetchDorms();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting dorm: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Admin Page'),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : dorms.isEmpty
              ? const Center(child: Text('No dorms available'))
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  itemCount: dorms.length,
                  itemBuilder: (context, index) {
                    final dorm = dorms[index];
                    return AdminCard(
                      dorm: dorm,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditDormPage(dorm: dorm),
                          ),
                        ).then((_) => _fetchDorms());
                      },
                      onDelete: () => _deleteDorm(dorm.id),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDormPage()),
          ).then((_) => _fetchDorms());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
