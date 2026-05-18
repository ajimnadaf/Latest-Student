import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImageViewerScreen extends StatefulWidget {
  final File file;

  const ImageViewerScreen({super.key, required this.file});

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = widget.file.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Homework")),
      backgroundColor: Colors.black,
      body: FutureBuilder<Uint8List>(
        future: _bytes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Unable to load image",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
