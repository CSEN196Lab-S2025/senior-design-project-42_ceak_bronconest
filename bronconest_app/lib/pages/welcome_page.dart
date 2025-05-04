import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bronconest_app/pages/home_page.dart';
import 'package:bronconest_app/pages/explore_page.dart';
import 'package:bronconest_app/pages/saved_places_page.dart';
import 'package:bronconest_app/widgets/nav_bar_scaffold.dart';
import 'package:bronconest_app/pages/admin_page.dart';
import 'package:bronconest_app/globals.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      userId = prefs.getString('userId') ?? '';
      userName = prefs.getString('userName') ?? '';
      school = prefs.getString('school') ?? '';
      isStudent = prefs.getBool('isStudent') ?? false;
      isAdmin = prefs.getBool('isAdmin') ?? false;

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => NavBarScaffold(
                  startingIndex: 1,
                  pages: [
                    ExplorePage(),
                    HomePage(),
                    SavedPlacesPage(),
                    if (isAdmin) AdminPage(),
                  ],
                  navigationDestination: [
                    NavigationDestination(
                      icon: Icon(Icons.search),
                      label: 'Explore',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.favorite),
                      label: 'Saved Places',
                    ),
                    if (isAdmin)
                      NavigationDestination(
                        icon: Icon(Icons.admin_panel_settings),
                        label: 'Admin Page',
                      ),
                  ],
                ),
          ),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final domain = user.email?.split('@')[1].split('.')[0];
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final DocumentReference schoolDoc = firestore
            .collection('schools')
            .doc(domain);
        final DocumentReference userDoc = firestore
            .collection('users')
            .doc(user.uid);
        final DocumentSnapshot userSnapshot = await userDoc.get();
        final DocumentSnapshot schoolSnapshot = await schoolDoc.get();
        final List<String> whitelist = [];
        if (schoolSnapshot.exists) {
          whitelist.addAll(List<String>.from(schoolSnapshot['whitelist']));
        }
        final bool isAdminNow =
            user.email != null && whitelist.contains(user.email);
        final bool isStudentNow =
            user.email != null && user.email!.endsWith('.edu');
        if (!userSnapshot.exists) {
          await userDoc.set({
            'id': user.uid,
            'name': user.displayName,
            'email': user.email,
            'isStudent': isStudentNow,
            'isAdmin': isAdminNow,
            'savedPlaces': [],
          });
        }
        school = domain ?? '';
        userId = user.uid;
        userName = user.displayName ?? '';
        isStudent = isStudentNow;
        isAdmin = isAdminNow;
        isLoggedIn = true;
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', userId);
      await prefs.setString('userName', userName);
      await prefs.setString('school', school);
      await prefs.setBool('isStudent', isStudent);
      await prefs.setBool('isAdmin', isAdmin);

      if (mounted) {
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => NavBarScaffold(
                  startingIndex: 1,
                  pages: [
                    ExplorePage(),
                    HomePage(),
                    SavedPlacesPage(),
                    if (isAdmin) AdminPage(),
                  ],
                  navigationDestination: [
                    NavigationDestination(
                      icon: Icon(Icons.search),
                      label: 'Explore',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.favorite),
                      label: 'Saved Places',
                    ),
                    if (isAdmin)
                      NavigationDestination(
                        icon: Icon(Icons.admin_panel_settings),
                        label: 'Admin Page',
                      ),
                  ],
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Welcome Page'),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 50.0,
                  children: [
                    const Text('Welcome Page'),
                    TextButton(
                      onPressed: () {
                        _signInWithGoogle();
                      },
                      child: const Text('Login!'),
                    ),
                  ],
                ),
              ),
    );
  }
}
