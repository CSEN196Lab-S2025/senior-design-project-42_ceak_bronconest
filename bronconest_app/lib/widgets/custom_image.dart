import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomImage extends StatefulWidget {
  const CustomImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  State<CustomImage> createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: BoxFit.cover,
      width: 2000, // lol this makes the cover fit the width
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
