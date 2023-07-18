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
  String backendResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery and Camera Access'),
        backgroundColor: const Color.fromARGB(255, 47, 66, 210),
        actions: const [],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 580,
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
            top: 580,
            left: 30,
            child: GestureDetector(
              onTap: () {
                // _showPicker(context, ImageSource.camera);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ARKitExample(func: print),
                  ),
                );
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
          if (galleryFile != null)
            Positioned(
              bottom: 0,
              child: FractionalTranslation(
                translation: const Offset(0, 0),
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: DecoratedBox(
                    decoration: BoxDecoration(),
                  ),
                ),
              ),
            ),
          // if (galleryFile != null)
          //   ARKitExample(), // Add ARKitExample widget to display AR content
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getGptResultFromBackend(context);
        },
        child: const Icon(Icons.send),
      ),
    );
  }

  void _showPicker(BuildContext context, ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        galleryFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _sendImageToBackend() async {
    if (galleryFile != null) {
      var result = await getGptResultFromBackend(galleryFile!);
      setState(() {
        backendResult = result;
      });
    }
  }

  Future<String> getGptResultFromBackend(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://35.234.108.24:8000/process_image'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

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

  void _getGptResultFromBackend(BuildContext context) async {
    if (galleryFile != null) {
      var result = await getGptResultFromBackend(galleryFile!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(result: result),
        ),
      );
    }
  }
}

class ARKitExample extends StatefulWidget {
  final Function func;
  const ARKitExample({Key? key, required this.func}) : super(key: key);

  @override
  _ARKitExampleState createState() => _ARKitExampleState();
}

class _ARKitExampleState extends State<ARKitExample> {
  late ARKitController arkitController;

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
                Container(
                  margin: EdgeInsets.only(top: 150.0),
                  child: Transform.scale(
                      scale: 4,
                      child: SvgPicture.asset(
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
                        },
                        icon: Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white, // Color of the icon
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add your onPressed logic here
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
                          // Add your onPressed logic here
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

  Future<int> getStreamLength(MemoryImage stream) async {
    return stream.bytes.length;
  }

  Future<String> getGptResultFromBackend(ImageProvider<Object> image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://35.234.108.24:8000/process_image'),
    );
    final completer = Completer<Uint8List>();
    final imageStream = image.resolve(ImageConfiguration.empty);

    imageStream
        .addListener(ImageStreamListener((imageInfo, synchronousCall) async {
      final byteData =
          await imageInfo.image.toByteData(format: ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      completer.complete(bytes);
    }));

    final bytes = await completer.future;
    final multipartFile =
        http.MultipartFile.fromBytes('image', bytes, filename: 'image.png');
    request.files.add(multipartFile);
    print(await multipartFile.finalize().length);
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
}
