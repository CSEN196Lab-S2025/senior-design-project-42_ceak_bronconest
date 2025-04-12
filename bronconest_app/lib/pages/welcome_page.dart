import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/pages/home_page.dart';
import 'package:bronconest_app/pages/explore_page.dart';
import 'package:bronconest_app/pages/saved_places_page.dart';
import 'package:bronconest_app/widgets/nav_bar_scaffold.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Future<void> _signInWithGoogle() async {
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
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final DocumentReference userDoc = firestore
            .collection('users')
            .doc(user.uid);
        final DocumentSnapshot userSnapshot = await userDoc.get();
        final bool isStudent =
            user.email != null && user.email!.endsWith('.edu');
        if (!userSnapshot.exists) {
          await userDoc.set({
            'id': user.uid,
            'name': user.displayName,
            'email': user.email,
            'isStudent': isStudent,
          });
        }
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => NavBarScaffold(
                  startingIndex: 1,
                  pages: [ExplorePage(), HomePage(), SavedPlacesPage()],
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
      body: Center(
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
