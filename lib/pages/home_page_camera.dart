import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:groceryapp/pages/gallery_page.dart';
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
import 'intro_screen.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.green),
      home: const ARKitExample(
        func: print,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ARKitExample extends StatefulWidget {
  final Function func;
  const ARKitExample({Key? key, required this.func}) : super(key: key);

  @override
  _ARKitExampleState createState() => _ARKitExampleState();
}

class _ARKitExampleState extends State<ARKitExample> {
  FlutterTts flutterTts = FlutterTts();
  TextEditingController _chatController = TextEditingController();
  List<String> chatHistory = [];
  late ARKitController arkitController;
  File galleryFile = File('');
  var isLoading = false;
  var isResult = false;
  String? resultData;
  final picker = ImagePicker();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ARKitSceneView(
            onARKitViewCreated: onARKitViewCreated,
          ),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  IntroScreen(), // Navigate to IntroScreen
                            ),
                          ); // Navigate back when the button is pressed
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.white,
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
                Container(
                  margin: EdgeInsets.only(top: 150.0),
                  child: Transform.scale(
                      scale: isLoading ? 0.5 : 4,
                      child: isLoading
                          ? Image.asset(
                              'lib/images/spinner.gif',
                            )
                          : SvgPicture.asset(
                              'lib/images/focus.svg', // Replace with your SVG file path
                              width: 100, // Adjust the width as needed
                              height: 100, // Adjust the height as needed
                            )),
                )
              ])),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 160, // Adjust the height as needed
              margin: EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          _showPicker(context, ImageSource.gallery);
                        },
                        icon: Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white, // Color of the icon
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (isLoading) return;
                      print('sent!');
                      setState(() {
                        isLoading = true;
                      });
                      final image = await arkitController.snapshot();
                      final imageFile = await _getImageFileFromProvider(image);
                      final result = await getGptResultFromBackend(imageFile);
                      print(result);
                      setState(() {
                        isLoading = false;
                      });
                      if (result != null) {
                        setState(() {
                          //isResult = true;
                          resultData = result;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(5.0),
                      shape: CircleBorder(),
                      primary: Colors.white, // White background for the button
                      onPrimary: Colors
                          .black, // Black color for the text/icon inside the button
                      elevation:
                          4.0, // Optional: Add some elevation for a shadow effect
                    ),
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors
                              .black, // Black border around the white circle
                          width: 8.0,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Material(
                      color:
                          Color(0xFF462B9C), // Background color of the button
                      borderRadius: BorderRadius.circular(
                          20.0), // Optional: Add rounded corners
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
                          color: Colors.white, // Color of the icon
                        ),
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
                              color: Color(0xff462b9c)),
                          padding:
                              EdgeInsets.only(left: 20, right: 20, top: 20),
                          child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Column(children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Result',
                                              style: TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isResult = false;
                                              });
                                            },
                                            icon: Icon(
                                              Icons.close_outlined,
                                              color: Colors
                                                  .white, // Color of the icon
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                                Text(
                                  '${resultData}',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _chatController,
                                          decoration: InputDecoration(
                                            hintText: 'Type your message...',
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _sendMessage,
                                        icon: Icon(Icons.send),
                                      ),
                                    ],
                                  ),
                                ),
                              ])))))
              : Container()
        ],
      ),
      // floatingActionButton:
      // FloatingActionButton(
      //   onPressed: () async {
      //     final image = await arkitController.snapshot();

      //     var result = await getGptResultFromBackend(image);
      //     print(result);
      //     if (result == null) {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => ResultPage(result: result),
      //         ),
      //       );
      //     }
      //   },
      //   child: const Icon(Icons.send),
      // ),
    );
  }

  Future<void> speakResult() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(0.6);
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.speak(resultData ?? ''); // Use resultData for speaking
  }

  Future<String?> getGptResultFromBackend(imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/process_image'),
    );

    final imageBytes = await imageFile.readAsBytes();
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

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
  }

  void addARKitNode(ARKitController arkitController) {
    final node = ARKitNode(
      geometry: ARKitSphere(radius: 0.1),
      position: vector_math.Vector3(0, 0, -0.5),
    );

    arkitController.add(node);
  }

  Future<File> _getImageFileFromProvider(
      ImageProvider<Object> imageProvider) async {
    final completer = Completer<Uint8List>();
    final imageStream = imageProvider.resolve(ImageConfiguration.empty);

    imageStream
        .addListener(ImageStreamListener((imageInfo, synchronousCall) async {
      final byteData =
          await imageInfo.image.toByteData(format: ImageByteFormat.png);
      final uint8List = byteData!.buffer.asUint8List();
      completer.complete(uint8List);
    }));

    final uint8List = await completer.future;

    // Create a temporary file to save the image
    final tempDir = await getTemporaryDirectory();
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final tempFile =
        File('${tempDir.path}/temp_image_${currentTime.toString()}.png');

    // Write the image bytes to the temporary file
    await tempFile.writeAsBytes(uint8List);

    // setState(() {
    //   galleryFile = tempFile;
    // });
    return tempFile;
  }

  void _showPicker(BuildContext context, ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        galleryFile = File(pickedFile.path);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryAccess(galleryFile: galleryFile),
          ),
        );
      });
    }
  }

  void _sendMessage() {
    String message = _chatController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        chatHistory.add("You: $message");
        // Add logic here to send the message to a chat server or handle it as needed
      });
      _chatController.clear();
    }
  }
}
