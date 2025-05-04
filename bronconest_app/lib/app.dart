import 'package:flutter/material.dart';
import 'package:bronconest_app/pages/welcome_page.dart';
import 'package:bronconest_app/styles.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BroncoNest',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Styles.customBlack,
          onPrimary: Colors.white,
          secondary: Styles.customBlack,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Styles.customBlack,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
    );
  }
}
