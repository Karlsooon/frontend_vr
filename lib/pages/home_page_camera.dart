import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'caption_page.dart';
import 'dart:convert';
import 'dart:developer';

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
                child: const Icon(Icons.photo_library),
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
                child: const Icon(Icons.camera_alt),
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

      // Send the image to the backend and navigate to the caption page
      await sendImageToBackend(galleryFile!);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CaptionPage(imageFile: galleryFile!)),
      );
    }
  }

  Future<void> annotateImage(File imagePath, String apiKey) async {
    final url = Uri.parse(
        'https://vision.googleapis.com/v1/images:annotate?key=$apiKey');

    final imageBytes = await imagePath.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final requestBody = jsonEncode({
      'requests': [
        {
          'image': {'content': base64Image},
          'features': [
            {'type': 'LABEL_DETECTION'},
            {'type': 'TEXT_DETECTION'},
            {'type': 'FACE_DETECTION'},
            {'type': 'WEB_DETECTION'},
            {'type': 'PRODUCT_SEARCH'},

            // Add more feature types as needed
          ],
        },
      ],
    });

    final response = await http.post(url, body: requestBody);

    if (response.statusCode == 200) {
      // Successful response
      final jsonResponse = jsonDecode(response.body);
      print(response.body.toString());
      print("*****************************************");
      debugPrint(response.body.toString());
      print("*****************************************");
    } else {
      // Handle other response codes
      print('Error: ${response.body}');
    }
  }

  Future<void> sendImageToBackend(File imageFile) async {
    annotateImage(imageFile, 'AIzaSyC9P-soLqC2RKaixM8JlP41A4LNf0YwxaQ');
    return;
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://vision.googleapis.com/v1/images:annotate?key=AIzaSyC9P-soLqC2RKaixM8JlP41A4LNf0YwxaQ'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        // Successful response
        var responseJson = await response.stream.bytesToString();
        // Parse the JSON response
        var caption = parseCaption(responseJson);
        // Display or process the caption as needed
        print('Caption: $caption');
      } else {
        // Handle other response codes
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String parseCaption(String responseJson) {
    // Parse the JSON response and extract the caption
    // Modify this method based on the structure of your response JSON
    // For example, if the response JSON has a key "caption" containing the caption string, you can use:
    // var jsonResponse = jsonDecode(responseJson);
    // var caption = jsonResponse['caption'];
    // return caption;

    // For testing purposes, return a dummy caption
    return 'Dummy Caption';
  }
}
