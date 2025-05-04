import 'package:flutter/material.dart';

class ExploreHousesPage extends StatefulWidget {
  const ExploreHousesPage({super.key});

  @override
  State<ExploreHousesPage> createState() => _ExploreDormsPageState();
}

class _ExploreDormsPageState extends State<ExploreHousesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Houses')),
      body: Center(child: Text('Explore Houses Page')),
    );
  }
}
