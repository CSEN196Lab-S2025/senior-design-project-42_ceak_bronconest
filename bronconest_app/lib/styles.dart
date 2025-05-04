import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  // Colors:
  static const Color customBlack = Color(0xFF1F1F1F);

  // Text Styles:
  static TextStyle homePageTitleTextStyle = GoogleFonts.onest(
    textStyle: TextStyle(
      fontSize: 35.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );

  static TextStyle largeTextStyle = GoogleFonts.onest(
    textStyle: TextStyle(fontSize: 24.0),
  );

  static TextStyle mediumTextStyle = GoogleFonts.onest(
    textStyle: TextStyle(fontSize: 18.0),
  );

  static TextStyle normalTextStyle = GoogleFonts.onest(
    textStyle: TextStyle(fontSize: 14.0),
  );

  static TextStyle smallTextStyle = GoogleFonts.onest(
    textStyle: TextStyle(fontSize: 12.0),
  );
}
