import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
        // User canceled the sign-in
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

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
        print("Error signing in: $e");
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
