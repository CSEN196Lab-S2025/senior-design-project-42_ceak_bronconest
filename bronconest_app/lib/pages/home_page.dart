import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/pages/welcome_page.dart';
import 'package:bronconest_app/globals.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> schools = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchools();
  }

  Future<void> _fetchSchools() async {
    try {
      final schoolsSnapshot =
          await FirebaseFirestore.instance.collection('schools').get();
      setState(() {
        schools = schoolsSnapshot.docs.map((doc) => doc.id).toList();
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching schools: $e')));
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('BroncoNest'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Page'),
            Text('School: $school'),
            Text('User ID: $userId'),
            isLoading
                ? const CircularProgressIndicator()
                : DropdownButton<String>(
                  value: schools.contains(school) ? school : null,
                  hint: const Text('Select a school'),
                  items:
                      schools.map((String schoolName) {
                        return DropdownMenuItem<String>(
                          value: schoolName,
                          child: Text(schoolName),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      school = newValue!;
                    });
                  },
                ),
            ElevatedButton(
              onPressed: () {
                _logout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
