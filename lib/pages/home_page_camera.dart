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
      await sendImageToBackend(galleryFile!);
    }
  }

//   Future<void> extractInfoFromJson(String jsonInfo, {int retryCount = 0}) async {
//   final prompt =
//       "From the provided JSON information and using article permalinks and pageTitles in json, please find the following details: person name, brand name, movie name, and building name. Additionally, retrieve the top 3 descriptions with the highest scores. Format the response as follows: [{person name} {brand name} {movie name} {building name} {description1} {description2} {description3}]. If any of the details cannot be found, leave them empty.";

//   final chatGptInput = "$prompt\n\n$jsonInfo";

//   final apiUrl =
//       'https://api.openai.com/v1/engines/gpt-3.5-turbo-0301/completions';
//   final apiKey =
//       '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'; // Replace with your ChatGPT API key
//   final response = await http.post(
//     Uri.parse(apiUrl),
//     headers: {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $apiKey',
//     },
//     body: jsonEncode({
//       'prompt': chatGptInput,
//       'max_tokens': 100,
//     }),
//   );

//   if (response.statusCode == 200) {
//     final jsonResponse = jsonDecode(response.body);
//     final completions = jsonResponse['choices'][0]['text'];

//     final extractedNames = extractNamesFromCompletion(completions);

//     if (extractedNames.length < 7 && retryCount < 2) {
//       print("Some information is missing. Trying again... (Attempt ${retryCount + 1})");
//       await extractInfoFromJson(jsonInfo, retryCount: retryCount + 1); // Try again recursively with an increased retry count
//     } else {
//       print("$extractedNames");
//       // Send the extracted names to Serper API
//       // await sendToSerper(extractedNames);
//     }
//   } else {
//     print('Error: ${response.body}');
//   }
// }


  // List<String> extractNamesFromCompletion(String completion) {
  //   final words = completion.split(',');
  //   final names =
  //       words.where((word) => word[0].toUpperCase() == word[0]).toList();
  //   return names;
  // }

  // Future<void> annotateImage(File imagePath, String apiKey) async {
  //   final url = Uri.parse(
  //       'https://vision.googleapis.com/v1/images:annotate?key=$apiKey');

  //   final imageBytes = await imagePath.readAsBytes();
  //   final base64Image = base64Encode(imageBytes);
  //   final requestBody = jsonEncode({
  //     'requests': [
  //       {
  //         'image': {'content': base64Image},
  //         'features': [
  //           {'type': 'WEB_DETECTION'},
  //           // {'type': 'PRODUCT_SEARCH'},
  //           // Add more feature types as needed
  //         ],
  //       },
  //     ],
  //   });

  //   final response = await http.post(url, body: requestBody);

  //   if (response.statusCode == 200) {
  //     // Successful response
  //     final jsonResponse = jsonDecode(response.body);
  //     print("*****************************************");
  //     debugPrint(response.body.toString());
  //     print("*****************************************");
  //     await extractInfoFromJson(response.body.toString());
  //   } else {
  //     // Handle other response codes
  //     print('Error: ${response.body}');
  //   }
  // }

Future<void> sendImageToBackend(String imagePath) async {
  var url = Uri.parse('https://your-backend-api-url.com/process-image/');
  
  var request = http.MultipartRequest('POST', url);
  request.files.add(await http.MultipartFile.fromPath('image', imagePath));
  
  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      print('Image successfully sent to the backend');
      // Process the response from the backend
      // For example, you can parse the JSON response
      // and display the extracted information in your UI
    } else {
      print('Failed to send the image to the backend');
    }
  } catch (e) {
    print('Error occurred while sending the image: $e');
  }
}
}
