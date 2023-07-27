import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'gpt.dart';

class GalleryAccess extends StatefulWidget {
  final File galleryFile;
  const GalleryAccess({Key? key, required this.galleryFile}) : super(key: key);

  @override
  State<GalleryAccess> createState() => _GalleryAccessState();
}

class _GalleryAccessState extends State<GalleryAccess> {
  FlutterTts flutterTts = FlutterTts();
  bool isResult = false;
  bool isLoading = false;
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
          isResult = true; // Automatically open the message_outlined page
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
    await flutterTts.setPitch(0.7);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(resultData ?? '');
  }

  Future<void> stopSpeech() async {
    await flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: FileImage(widget.galleryFile),
            fit: BoxFit.contain,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 67,
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Padding added to move Button 1 to the right
                    Padding(
                      padding: const EdgeInsets.only(right: 90.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatApp(), // Navigate to the ChatApp page
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 255, 255, 255),
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Container(
                          width: 90,
                          height: 27,
                          child: Center(
                            child: Text(
                              'chat',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black, // Change text color here
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),

                    // Existing code...

                    // Padding added to move Button 3 to the left
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (!isLoading) {
                            setState(() {
                              isResult = true;
                            });
                          }
                          // Add your functionality here for Button 3
                          print('Button 2 clicked!');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 249, 249, 249),
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Container(
                          width: 90,
                          height: 27,
                          child: Center(
                            child: Text(
                              'show',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black, // Change text color here
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                            Navigator.pop(
                                context); // Navigate back when the button is pressed
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Color.fromARGB(
                                255, 255, 255, 255), // Color of the icon
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
            isResult
                ? Expanded(
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Container(
                        width: double
                            .infinity, // Make the container fill the entire width
                        height: 600,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Color.fromARGB(255, 255, 255, 255),
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
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isResult = false;
                                          });
                                          stopSpeech(); // Stop speech when the message_outlined page is closed
                                        },
                                        icon: Icon(
                                          Icons.close_outlined,
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          size: 35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                // Use Expanded to make the result text fill the available space
                                child: SingleChildScrollView(
                                  // Add SingleChildScrollView to enable scrolling if the content overflows
                                  child: Text(
                                    '${resultData}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
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
