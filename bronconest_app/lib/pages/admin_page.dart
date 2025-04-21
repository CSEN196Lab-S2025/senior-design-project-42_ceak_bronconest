import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/globals.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final CollectionReference dormsCollection = FirebaseFirestore.instance
      .collection('schools')
      .doc(school)
      .collection('dorms');

  void _addDorm() {
    showDialog(
      context: context,
      builder: (context) {
        String dormName = '';
        return AlertDialog(
          title: const Text('Add Dorm'),
          content: TextField(
            onChanged: (value) => dormName = value,
            decoration: const InputDecoration(hintText: 'Enter dorm name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (dormName.isNotEmpty) {
                  dormsCollection.add({'name': dormName});
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Dorm $dormName added')));
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
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
                dormsCollection.doc(dormId).delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Dorm deleted')));
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Admin Page'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dormsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No dorms available'));
          }
          final dorms = snapshot.data!.docs;
          return ListView.builder(
            itemCount: dorms.length,
            itemBuilder: (context, index) {
              final dorm = dorms[index];
              return ListTile(
                title: Text(dorm['name']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Edit dorm functionality
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteDorm(dorm.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDorm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
