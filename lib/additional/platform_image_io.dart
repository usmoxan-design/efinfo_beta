import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget getPlatformImage(String imageUrl) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    fit: BoxFit.fill,
    placeholder: (context, url) => const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyan),
      ),
    ),
    errorWidget: (context, url, error) =>
        const Icon(Icons.broken_image, color: Colors.white24, size: 30),
  );
}
