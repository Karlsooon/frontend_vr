import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CaptionPage extends StatelessWidget {
  final File imageFile;

  const CaptionPage({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Caption'),
        backgroundColor: Color.fromARGB(255, 47, 66, 210),
      ),
      body: FutureBuilder(
        future: fetchImageCaption(imageFile),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error occurred'));
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  snapshot.data ?? 'No caption available',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<String> fetchImageCaption(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/image-caption'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var jsonResponse = await response.stream.bytesToString();
        var parsedResponse = json.decode(jsonResponse);
        var caption = parsedResponse['captions'];
        return caption;
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
