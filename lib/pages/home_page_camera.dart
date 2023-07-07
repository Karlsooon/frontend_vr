import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'history_page.dart';
import 'package:path/path.dart' as path;


void main() {
  runApp(const MyApp());
}
final einsteinImagePath = path.join('lib/', 'images/', 'einstein.png');
final einsteinImage = File(einsteinImagePath);

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
  String? historyParagraph;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery and Camera Access'),
        backgroundColor: const Color.fromARGB(255, 47, 66, 210),
        actions: [],
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
            child: Stack(
              children: [
                SizedBox(
                  height: 200.0,
                  width: 300.0,
                  child: galleryFile == null
                      ? const Center(child: Text('Sorry, nothing selected!'))
                      : Image.file(galleryFile!),
                ),
                if (galleryFile != null)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.8,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(einsteinImage),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  if (historyParagraph != null) {
                    _navigateToHistoryPage(historyParagraph!);
                  }
                },
                child: const Text('View History'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHistoryPage(String historyParagraph) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(historyParagraph: historyParagraph),
      ),
    );
  }

  void _showPicker(BuildContext context, ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        galleryFile = File(pickedFile.path);
      });

      // Send the image to the backend and retrieve the paragraph description
      final apiKey = 'AIzaSyCYP2i5j5TOs3k8MwmFnvGVqoE0amU52A0';
      final paragraph = await generateHistoryParagraph(galleryFile!, apiKey);

      if (paragraph.isNotEmpty) {
        setState(() {
          historyParagraph = paragraph;
        });
      } else {
        print('No words found');
      }
    }
  }

  Future<String> generateHistoryParagraph(File imagePath, String apiKey) async {
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
        return await generateParagraphFromWords(top5Words);
      } else {
        print('No words found');
        return '';
      }
    } else {
      print('Error: ${response.body}');
      return '';
    }
  }

  Future<String> generateParagraphFromWords(List<String> wordList) async {
    const apiKey = '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';
    const url =
        'https://api.openai.com/v1/engines/text-davinci-003/completions';

    final prompt = '''
The five main words are: ${wordList.join(", ")}.
Please generate a paragraph describing the significance of these 5 words in three sentences.
You can be creative and provide informative information using numbers and data. And always finish the sentence. Be creative.
''';
    final requestBody = jsonEncode({
      'prompt': prompt,
      'max_tokens': 100,
      'temperature': 0.2,
      'n': 3,
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
          .whereType<Map<String, dynamic>>()
          .map((choice) => choice['text'].toString())
          .toList();

      final paragraphs = completions.join(' ').split('. ');
      final firstThreeSentences = paragraphs.sublist(0, 3).join('. ');

      return firstThreeSentences;
    } else {
      print('Error: ${response.body}');
      return '';
    }
  }
}
