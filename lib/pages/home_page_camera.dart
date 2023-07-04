import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.green),
      home: const GalleryAccess(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GalleryAccess extends StatefulWidget {
  const GalleryAccess({Key? key});

  @override
  State<GalleryAccess> createState() => _GalleryAccessState();
}

class _GalleryAccessState extends State<GalleryAccess> {
  File? galleryFile;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery and Camera Access'),
        backgroundColor: Color.fromARGB(255, 47, 66, 210),
        actions: const [],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 630,
            right: 20,
            child: GestureDetector(
              onTap: () {
                _showPicker(context, ImageSource.gallery);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.photo_library),
              ),
            ),
          ),
          Positioned(
            top: 630,
            left: 30,
            child: GestureDetector(
              onTap: () {
                _showPicker(context, ImageSource.camera);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.camera_alt),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              height: 200.0,
              width: 300.0,
              child: galleryFile == null
                  ? const Center(child: Text('Sorry, nothing selected!'))
                  : Image.file(galleryFile!),
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context, ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        galleryFile = File(pickedFile.path);
      });
    }
  }
}
