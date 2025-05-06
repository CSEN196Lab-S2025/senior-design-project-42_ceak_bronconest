import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bronconest_app/globals.dart';
import 'package:bronconest_app/styles.dart';

class FilterDormsPage extends StatefulWidget {
  const FilterDormsPage({super.key});

  @override
  State<FilterDormsPage> createState() => _FilterDormsPageState();
}

class _FilterDormsPageState extends State<FilterDormsPage> {
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
      // final allDorms =
      //     await FirebaseFirestore.instance
      //         .collection('schools')
      //         .doc(school)
      //         .collection('dorms')
      //         .get();

      // final dormIds = allDorms.docs.map((doc) => doc.id).toList();

      // Sample sort by walkability
      // dormIds.sort((a, b) {
      //   final dormA = allDorms.docs.firstWhere((doc) => doc.id == a);
      //   final dormB = allDorms.docs.firstWhere((doc) => doc.id == b);

      //   final walkabilityA = dormA.data()['walkability'] ?? 0;
      //   final walkabilityB = dormB.data()['walkability'] ?? 0;

      //   return walkabilityB.compareTo(walkabilityA);
      // });

      final response = await http.get(
        Uri.parse(
          'https://us-central1-bronconest-d1f01.cloudfunctions.net/rank_dorms?query=${_filterController.text}&school=$school',
        ),

        //Test API URL
        // Uri.parse(
        //   'http://0.0.0.0:3000/rank_dorms?query=${_filterController.text}',
        // ),
      );

      if (mounted) {
        final responseData = json.decode(response.body);
        final List<String> sortedIds = List<String>.from(
          responseData['sorted_ids'],
        );

        // Placeholder
        // final sortedIds = dormIds;

        Navigator.of(context).pop(sortedIds);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Filter applied')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error applying filter: $e')));
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
          child:
              isLoading
                  ? Center(
                    child: Column(
                      children: const [
                        SizedBox(height: 300), // fake center lol
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Curating your dorm list...',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      const Text(
                        'Please tell us how you would like to filter the selection of dorms.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Text(
                        'Using the power of AI, we will filter the dorms based on your custom input. Things like "I want a dorm close to campus" and "I want a dorm with a good community" give a better rating.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _filterController,
                        decoration: const InputDecoration(
                          labelText: "Put whatever you'd like!",
                          border: OutlineInputBorder(),
                        ),
                        minLines: 7,
                        maxLines: 7,
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: _submitFilter,
                        child: SizedBox(
                          height: 50,
                          width: 100,
                          child: Center(
                            child: Text(
                              'Apply Filter',
                              style: Styles.normalTextStyle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
