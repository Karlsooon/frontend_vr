import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

      // Send the image to the backend and retrieve the top 5 words
      final apiKey = 'AIzaSyCYP2i5j5TOs3k8MwmFnvGVqoE0amU52A0';
      final wordList = await annotateImage(galleryFile!, apiKey);

      if (wordList.isNotEmpty) {
        final historyParagraph = await generateHistoryParagraph(wordList);
        print('History Paragraph: $historyParagraph');
      } else {
        print('No words found');
      }
    }
  }

  // Future<List<String>> getTop5Words(String apiKey) async {
  //   final url = Uri.parse(
  //       'https://vision.googleapis.com/v1/images:annotate?key=$apiKey');
  //   final imageBytes = await galleryFile!.readAsBytes();
  //   final base64Image = base64Encode(imageBytes);

  //   final requestBody = jsonEncode({
  //     'requests': [
  //       {
  //         'image': {'content': base64Image},
  //         'features': [
  //           {'type': 'WEB_DETECTION'},
  //         ],
  //       },
  //     ],
  //   });

  //   final response = await http.post(url, body: requestBody);

  //   if (response.statusCode == 200) {
  //     final jsonResponse = jsonDecode(response.body);
  //     final webEntities =
  //         jsonResponse['responses'][0]['webDetection']['webEntities'];
  //     final sortedEntities = List.from(webEntities);
  //     sortedEntities.sort((a, b) => b['score'].compareTo(a['score']));
  //     final nonNullWords = sortedEntities
  //         .where((word) =>
  //             word.containsKey('description') &&
  //             word['description'].runtimeType == String)
  //         .take(5)
  //         .map<String>((word) => word['description'].toString())
  //         .toList();

  //     for (var i = 0; i < nonNullWords.length; i++) {
  //       print(nonNullWords[i]);
  //     }
  //     return nonNullWords;
  //   } else {
  //     print('Error: ${response.body}');
  //     return <String>[];
  //   }
  // }

  Future<List<String>> annotateImage(File imagePath, String apiKey) async {
    final url = Uri.parse(
        'https://vision.googleapis.com/v1/images:annotate?key=$apiKey');

    final imageBytes = await imagePath.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final requestBody = jsonEncode({
      'requests': [
        {
          'image': {'content': base64Image},
          'features': [
            {'type': 'WEB_DETECTION'},
            // {'type': 'FACE_DETECTION'},
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

      // Extract the top 5 words with the highest scores
      final webEntities =
          jsonResponse['responses'][0]['webDetection']['webEntities'];
      final sortedEntities = List.from(webEntities);
      sortedEntities.sort((a, b) => b['score'].compareTo(a['score']));
      final top5Words = <String>[];
      for (var i = 0; i < sortedEntities.length; i++) {
        if (top5Words.length >= 5) {
          break;
        }

        if (sortedEntities[i].containsKey('description') &&
            sortedEntities[i]['description'] is String) {
          top5Words.add(sortedEntities[i]['description'].toString());
        } 
      }

      if (top5Words.isNotEmpty) {
        return top5Words;
      } else {
        print('No words found');
        return [];
      }
    } else {
      // Handle other response codes
      print('Error: ${response.body}');
      return [];
    }
  }

  Future<String> generateHistoryParagraph(List<String> wordList) async {
    final apiKey =
        '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'; // Replace with your OpenAI API key
    final url =
        'https://api.openai.com/v1/engines/text-davinci-003/completions'; // Use the Davinci-Codex model

    final nonNullWords = wordList.whereType<String>().toList();
    if (nonNullWords.isEmpty) {
      print('No words found');
      return '';
    }

    final prompt = 'The five main words are: ${nonNullWords.join(", ")}';
    final requestBody = jsonEncode({
      'prompt': prompt,
      'max_tokens': 100,
      'temperature': 0.7,
      'n': 1,
      // 'stop': ['Flutter:Word:', 'null']
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final completions = jsonResponse['choices']
          .whereType<Map<String, dynamic>>() // Filter out null values
          .map((choice) => choice['text'].toString())
          .toList();

      print('Completions: $completions'); // Print completions for debugging

      return completions.join(' ');
    } else {
      // Handle other response codes
      print('Error: ${response.body}');
      return '';
    }
  }

  Future<void> sendImageToBackend(File imageFile) async {
    annotateImage(imageFile, 'AIzaSyCYP2i5j5TOs3k8MwmFnvGVqoE0amU52A0');
    return;
  }

  String parseCaption(String responseJson) {
    // Parse the JSON response and extract the caption
    try {
      final jsonResponse = jsonDecode(responseJson);
      final caption = jsonResponse['caption'];
      return caption;
    } catch (e) {
      print('Error parsing caption: $e');
      return '';
    }
  }
}
