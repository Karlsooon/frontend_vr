import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'home_page_camera.dart';

class GalleryAccess extends StatefulWidget {
  final File galleryFile;
  const GalleryAccess({Key? key, required this.galleryFile}) : super(key: key);

  @override
  State<GalleryAccess> createState() => _GalleryAccessState();
}

class _GalleryAccessState extends State<GalleryAccess> {
  FlutterTts flutterTts = FlutterTts();
  bool isPlayerOn = false;
  var isResult = false;
  var isLoading = false;
  String? resultData;

  @override
  void initState() {
    super.initState();
    _getResultFromBackend();
  }

  Future<void> _getResultFromBackend() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Create a multipart request for sending the image
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://35.234.108.24:8000/process_image'),
      );

      // Add the image file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // The field name should match the one in the Django view
          widget.galleryFile.path,
        ),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        setState(() {
          isLoading = false;
          resultData = responseBody;
        });
        speakResult(); // Speak the result when it's received
      } else {
        setState(() {
          isLoading = false;
          resultData = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        resultData = 'Error: $e';
      });
    }
  }

  Future<void> speakResult() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(0.6);
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.speak(resultData ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(widget.galleryFile),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Container(
                    height: 80,
                    margin: EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ARKitExample(
                                    func: print), // Navigate to IntroScreen
                              ),
                            ); // Navigate back when the button is pressed
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
                  Transform.scale(
                    scale: 0.5,
                    child: isLoading
                        ? Image.asset(
                            'lib/images/spinner.gif',
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 160,
                margin: EdgeInsets.only(bottom: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Material(
                        color: Color(0xFF462B9C),
                        borderRadius: BorderRadius.circular(20.0),
                        child: IconButton(
                          onPressed: () {
                            if (!isLoading) {
                              setState(() {
                                isResult = true;
                              });
                            }
                          },
                          icon: Icon(
                            Icons.message_outlined,
                            color: Colors.white,
                          ),
                          iconSize: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isResult
                ? Expanded(
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Container(
                        width: 430,
                        height: 491,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Color(0xff462b9c),
                        ),
                        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Result',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isResult = false;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.close_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                '${resultData}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

