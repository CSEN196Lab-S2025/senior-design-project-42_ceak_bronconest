import 'package:flutter/material.dart';

//ignore: must_be_immutable
class ImageGradientOverlay extends StatefulWidget {
  ImageGradientOverlay({
    super.key,
    this.startLocation = Alignment.topCenter,
    this.endLocation = Alignment.center,
    this.startColor,
    this.endColor = Colors.transparent,
  });

  Alignment startLocation;
  Alignment endLocation;

  late Color? startColor;
  Color endColor;

  @override
  State<ImageGradientOverlay> createState() => _ImageGradientOverlayState();
}

class _ImageGradientOverlayState extends State<ImageGradientOverlay> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: widget.startLocation,
            end: widget.endLocation,
            colors: [
              widget.startColor ?? Color.fromARGB(75, 0, 0, 0),
              widget.endColor,
            ],
          ),
        ),
      ),
    );
  }
}
