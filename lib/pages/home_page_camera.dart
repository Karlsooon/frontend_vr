import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'caption_page.dart';
import 'dart:convert';
import 'dart:developer';
import 'chat_history.dart';

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
      await annotateImage(galleryFile!, apiKey);

      // Generate a historical paragraph using the top 5 words
      final wordList = await getTop5Words(apiKey);
      if (wordList.isNotEmpty) {
        final historyParagraph = await generateHistoryParagraph(wordList);
        print('History Paragraph: $historyParagraph');
      } else {
        print('No words found');
      }

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => CaptionPage(imageFile: galleryFile!),
      //   ),
      // );
    }
  }

  Future<List<String>> getTop5Words(String apiKey) async {
    final url = Uri.parse(
        'https://vision.googleapis.com/v1/images:annotate?key=$apiKey');
    final imageBytes = await galleryFile!.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final requestBody = jsonEncode({
      'requests': [
        {
          'image': {'content': base64Image},
          'features': [
            {'type': 'WEB_DETECTION'},
          ],
        },
      ],
    });

    final response = await http.post(url, body: requestBody);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final webEntities =
          jsonResponse['responses'][0]['webDetection']['webEntities'];
      final sortedEntities = List.from(webEntities);
      sortedEntities.sort((a, b) => b['score'].compareTo(a['score']));
      final top5Words = sortedEntities
          .map<String>((word) => word['description'].toString())
          .take(5)
          .toList();
      return top5Words;
    } else {
      print('Error: ${response.body}');
      return <String>[];
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
      final top5Words = sortedEntities.take(5).toList();

      if (top5Words.isNotEmpty) {
        final wordList = top5Words
            .map((word) => word['description'])
            .toList()
            .cast<String>();
        final historyParagraph = await generateHistoryParagraph(wordList);
        print('History Paragraph: $historyParagraph');
      } else {
        print('No words found');
      }
    } else {
      // Handle other response codes
      print('Error: ${response.body}');
    }
  }

Future<String> generateHistoryParagraph(List<String> wordList) async {
  final apiKey = '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'; // Replace with your OpenAI API key
  final url = 'https://api.openai.com/v1/engines/text-davinci-003/completions'; // Use the Davinci-Codex model

  final prompt = 'The five main words are: ${wordList.join(", ")}';
  final requestBody = jsonEncode({
<<<<<<< HEAD
    'prompt': prompt,
    'max_tokens': 100,
    'temperature': 0.7,
    'n': 3,
    'stop': ['Flutter:Word:', 'null']
=======
    'requests': [
      {
        'image': {'content': base64Image},
        'features': [
          {'type': 'WEB_DETECTION'},
          // {'type': 'FACE_DETECTION'},
        ],
      },
    ],
>>>>>>> 2a5106de6b6d91ffac794cf9e3eb17d6353775f2
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
    final completions = jsonResponse['choices'].map((choice) => choice['text']).toList();
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
    // var request = http.MultipartRequest(
    //   'POST',
    //   Uri.parse(
    //       'https://vision.googleapis.com/v1/images:annotate?key=AIzaSyC9P-soLqC2RKaixM8JlP41A4LNf0YwxaQ'),
    // );
    // request.files.add(
    //   await http.MultipartFile.fromPath('file', imageFile.path),
    // );

    // try {
    //   var response = await request.send();
    //   if (response.statusCode == 200) {
    //     // Successful response
    //     var responseJson = await response.stream.bytesToString();
    //     // Parse the JSON response
    //     var caption = parseCaption(responseJson);
    //     // Display or process the caption as needed
    //     print('Caption: $caption');
    //   } else {
    //     // Handle other response codes
    //     print('Error: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   print('Error: $e');
    // }
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
