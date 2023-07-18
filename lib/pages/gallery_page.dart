import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;
import 'result_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GalleryAccess extends StatefulWidget {
  final File galleryFile;
  const GalleryAccess({Key? key, required this.galleryFile}) : super(key: key);

  @override
  State<GalleryAccess> createState() => _GalleryAccessState();
}

class _GalleryAccessState extends State<GalleryAccess> {
    Future<String>? _result;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: FileImage(widget.galleryFile),
          fit: BoxFit.cover,
        )),
        child: Stack(
          children: [
            Align(
                alignment: Alignment.topCenter,
                child: Column(children: [
                  Container(
                    height: 80,
                    margin: EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            // Add your onPressed logic here
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Colors.white, // Color of the icon
                          ),
                          iconSize: 35,
                        ),
                        IconButton(
                          onPressed: () {
                            // Add your onPressed logic here
                          },
                          icon: Icon(
                            Icons.light_mode_outlined,
                            color: Colors.white, // Color of the icon
                          ),
                          iconSize: 35,
                        ),
                      ],
                    ),
                  ),
                ])),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 160, // Adjust the height as needed
                margin: EdgeInsets.only(bottom: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Material(
                        color:
                            Color(0xFF462B9C), // Background color of the button
                        borderRadius: BorderRadius.circular(
                            20.0), // Optional: Add rounded corners
                        child: IconButton(
                          onPressed: () {
                            // Add your onPressed logic here
                          },
                          icon: Icon(
                            Icons.monitor_heart_outlined,
                            color: Colors.white, // Color of the icon
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 1),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Material(
                        color:
                            Color(0xFF462B9C), // Background color of the button
                        borderRadius: BorderRadius.circular(
                            20.0), // Optional: Add rounded corners
                        child: IconButton(
                          onPressed: () async {
                            // Send the chosen image to the backend and get the result
                            // _result = getGptResultFromBackend();
                            // var result = await _result;

                            // if (result != null) {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => ResultPage(result: result),
                            //     ),
                            //   );
                            // }
                          },
                          icon: Icon(
                            Icons.message_outlined,
                            color: Colors.white, // Color of the icon
                          ),
                          iconSize: 60,
                        ),
                      ),
                    ),
                    SizedBox(width: 1),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Material(
                        color:
                            Color(0xFF462B9C), // Background color of the button
                        borderRadius: BorderRadius.circular(
                            20.0), // Optional: Add rounded corners
                        child: IconButton(
                          onPressed: () {
                            // Add your onPressed logic here
                          },
                          icon: Icon(
                            Icons.delete_outline_outlined,
                            color: Colors.white, // Color of the icon
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
    Future<String?> getGptResultFromBackend() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://35.234.108.24:8000/process_image'),
    );

    final imageBytes = await widget.galleryFile.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: 'image.png',
    );
    request.files.add(multipartFile);

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var caption = await response.stream.bytesToString();
        return caption;
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
