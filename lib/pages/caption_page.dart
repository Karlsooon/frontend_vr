import 'dart:convert';
import 'package:flutter/material.dart';

class CaptionPage extends StatelessWidget {
  final String caption;

  const CaptionPage({required this.caption});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Caption'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _extractCaptionText(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }

  String _extractCaptionText() {
    try {
      var jsonMap = json.decode(caption) as Map<String, dynamic>;
      var captions = jsonMap['captions'] as List<dynamic>;
      if (captions.isNotEmpty) {
        var firstCaption = captions.first;
        return firstCaption['caption'] ?? '';
      }
    } catch (e) {
      // Handle JSON decoding errors or missing data here
      print('Error while decoding JSON: $e');
    }
    return 'Caption not available';
  }
}
