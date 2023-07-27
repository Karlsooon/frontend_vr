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
import 'package:flutter_svg/flutter_svg.dart';
import 'intro_screen.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'gpt.dart';

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
  bool flash = false;
  late CameraController _cameraController;
  FlashMode _flashMode = FlashMode.off;
  FlutterTts flutterTts = FlutterTts();
  TextEditingController _chatController = TextEditingController();
  List<String> chatHistory = [];
  late ARKitController arkitController;
  File galleryFile = File('');
  var isLoading = false;
  var isResult = false;
  String? resultData;
  final picker = ImagePicker();

  bool isMessageOpen = false; // Track if the message page is open
  bool isSpeaking = false; // Track if speech is currently being played

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isIpad = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      body: Stack(
        children: [
          ARKitSceneView(
            onARKitViewCreated: onARKitViewCreated,
          ),
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
                    padding: const EdgeInsets.only(right: 8.0),
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
                        width: 60,
                        height: 27,
                        child: Center(
                          child: Text(
                            'chat',
                            style: TextStyle(
                              fontSize: 13,
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
                        width: 60,
                        height: 27,
                        child: Center(
                          child: Text(
                            'show',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black, // Change text color here
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Add some space between buttons
                  SizedBox(width: 16),

                  // Existing code...

                  // Padding added to move Button 3 to the left
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your functionality here for Button 3
                        print('Button 3 clicked!');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 255, 255, 255),
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Container(
                        width: 60,
                        height: 27,
                        child: Center(
                          child: Text(
                            'assistant',
                            style: TextStyle(
                              fontSize: 13,
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
                  margin: EdgeInsets.only(top: 40.0, left: .0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IntroScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.white,
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
                            'lib/images/focus.svg',
                            width: 100,
                            height: 100,
                          ),
                  ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Material(
                      color: Color.fromARGB(255, 254, 254, 254),
                      borderRadius: BorderRadius.circular(20.0),
                      child: IconButton(
                        onPressed: () {
                          _showPicker(context, ImageSource.gallery);
                        },
                        icon: Icon(
                          Icons.photo_library_outlined,
                          color: Colors.black,
                          size: screenWidth * 0.08, // Adjust the b
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
                          isResult = true;
                          resultData = result;
                          isMessageOpen =
                              true; // Open the message page automatically
                        });
                        toggleSpeech(); // Start speaking the result
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          isIpad ? EdgeInsets.all(10.0) : EdgeInsets.all(5.0),
                      shape: CircleBorder(),
                      primary: Colors.white,
                      onPrimary: Colors.black,
                      elevation: 4.0,
                    ),
                    child: Container(
                      width: isIpad ? 120.0 : 100.0,
                      height: isIpad ? 100.0 : 80.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 8.0,
                        ),
                      ),
                    ),
                  ),
                  Container()
                ],
              ),
            ),
          ),
          Visibility(
            visible: isResult &&
                isMessageOpen, // Show the message page only when isResult and isMessageOpen are true
            child: Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  width: 430,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Result',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isMessageOpen =
                                          false; // Close the message page
                                    });
                                    stopSpeaking(); // Stop the speech when closing the message page
                                  },
                                  icon: Icon(
                                    Icons.close_outlined,
                                    color: const Color.fromARGB(255, 0, 0, 0),
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
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> toggleSpeech() async {
    if (isSpeaking) {
      await flutterTts.stop();
    } else {
      await flutterTts.setLanguage('en-US');
      await flutterTts.setPitch(0.7);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.speak(resultData ?? ''); // Use resultData for speaking
    }

    setState(() {
      isSpeaking = !isSpeaking;
    });
  }

  Future<void> stopSpeaking() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    }
  }

  Future<String?> getGptResultFromBackend(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://35.234.108.24:8000/process_image'),
    );

    final imageBytes = await imageFile.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'file', // Make sure 'file' matches the key used in the backend
      imageBytes,
      filename: 'image.png',
    );
    request.files.add(multipartFile);

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        return responseBody;
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

    final tempDir = await getTemporaryDirectory();
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final tempFile =
        File('${tempDir.path}/temp_image_${currentTime.toString()}.png');

    await tempFile.writeAsBytes(uint8List);

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
}
