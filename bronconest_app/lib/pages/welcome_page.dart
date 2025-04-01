import 'package:flutter/material.dart';
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
              },
              child: const Text('Login!'),
            ),
          ],
        ),
      ),
    );
  }
}
