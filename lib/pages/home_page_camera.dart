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
      Uri.parse('http://localhost:8000/process_image'),
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

class ResultPage extends StatefulWidget {
  final String result;

  const ResultPage({Key? key, required this.result}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    speakResult();
  }

  Future<void> speakResult() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(0.6);
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.speak(widget.result);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          widget.result,
          style: const TextStyle(fontSize: 18),
        ),
      ),
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
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final image = await arkitController.snapshot();

          var result = await getGptResultFromBackend(image);
          print(result);
          if (result == null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultPage(result: result),
              ),
            );
          }
        },
        child: const Icon(Icons.send),
      ),
    );
  }

  Future<int> getStreamLength(MemoryImage stream) async {
    return stream.bytes.length;
  }

  Future<String> getGptResultFromBackend(ImageProvider<Object> image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/process_image'),
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
    addARKitNode(arkitController);
  }

  void addARKitNode(ARKitController arkitController) {
    final node = ARKitNode(
      geometry: ARKitSphere(radius: 0.1),
      position: vector_math.Vector3(0, 0, -0.5),
    );

    arkitController.add(node);
  }
}
