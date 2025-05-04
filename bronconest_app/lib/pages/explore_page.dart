import 'package:flutter/material.dart';
import 'package:bronconest_app/pages/explore_dorms_page.dart';
import 'package:bronconest_app/pages/explore_houses_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Explore'),
          bottom: const TabBar(tabs: [Tab(text: 'Dorms'), Tab(text: 'Houses')]),
        ),
        body: const TabBarView(
          children: [ExploreDormsPage(), ExploreHousesPage()],
        ),
      ),
    );
  }
}
