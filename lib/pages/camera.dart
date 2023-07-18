import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const IntroScreen(),
    );
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  CameraController? _cameraController;
  late Future<void> _initializeCameraController;

  @override
  void initState() {
    super.initState();
    _initializeCameraController = initCameraController();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> initCameraController() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
    );
    await _cameraController?.initialize();
  }

  void takePicture() async {
    if (_cameraController != null &&
        !_cameraController!.value.isTakingPicture) {
      try {
        final XFile? picture = await _cameraController?.takePicture();
        if (picture != null) {
          // Use the picture file here as needed
        }
      } catch (e) {
        // Handle camera errors
        print('Error taking picture: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cameraController != null
          ? CameraPreview(_cameraController!)
          : Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: takePicture,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
