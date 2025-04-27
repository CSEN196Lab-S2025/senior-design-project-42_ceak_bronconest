import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/globals.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final TextEditingController _filterController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _submitFilter() async {
    if (_filterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text for filter')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final allDorms =
          await FirebaseFirestore.instance
              .collection('schools')
              .doc(school)
              .collection('dorms')
              .get();

      final dormsJson =
          allDorms.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'walkability': data['walkability_avg'],
              'cleanliness': data['cleanliness_avg'],
              'quietness': data['quietness_avg'],
              'comfort': data['comfort_avg'],
              'safety': data['safety_avg'],
              'amenities': data['amenities_avg'],
              'community': data['community_avg'],
            };
          }).toList();

      // Sample sort by walkability
      dormsJson.sort(
        (a, b) => (b['walkability'] as num).compareTo(a['walkability'] as num),
      );

      // final requestBody = {
      //   'prompt': _filterController.text,
      //   'dorms': dormsJson,
      // };

      // final response = await http.post(
      //   Uri.parse('https://api.bronconest.com/filter'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: requestBody,
      // );

      if (mounted) {
        // final sortedIds = List<String>.from(
        //   jsonDecode(response.body)['sortedIds'],
        // );

        // Placeholder
        final sortedIds = dormsJson.map((dorm) => dorm['id']).toList();
        Navigator.of(context).pop(sortedIds);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Fliter applied')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error applying fliter: $e')));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filter Dorms')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Please tell us how you would like to filter the selection of dorms.',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'Using the power of AI, we will filter the dorms based on your custom input. Things like "I want a dorm close to campus" and "I want a dorm with a good community" give a better rating.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              TextField(
                controller: _filterController,
                decoration: const InputDecoration(
                  labelText: "Put whatever you'd like!",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _submitFilter,
                child:
                    isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Apply Filter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
