import 'package:flutter/material.dart';

class NavBarScaffold extends StatefulWidget {
  const NavBarScaffold({
    super.key,
    required this.pages,
    required this.navigationDestination,
    this.startingIndex = 0,
  });

  final List<Widget> pages;
  final List<NavigationDestination> navigationDestination;
  final int startingIndex;

  @override
  State<NavBarScaffold> createState() => _NavBarScaffoldState();
}

class _NavBarScaffoldState extends State<NavBarScaffold> {
  late int currentPageIndex;

  @override
  void initState() {
    super.initState();

    currentPageIndex = widget.startingIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        height: 60.0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: widget.navigationDestination,
      ),
      body: widget.pages[currentPageIndex],
    );
  }
}
