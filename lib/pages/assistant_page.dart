// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_tts/flutter_tts.dart';
// import 'dart:convert';

// class VideoPlayerScreen extends StatefulWidget {
//   @override
//   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late VideoPlayerController _controller;
//   late Future<void> _initializeVideoPlayerFuture;
//   TextEditingController _textInputController = TextEditingController();
//   bool _isSpeaking = false; // Flag to track TTS state
//   final FlutterTts flutterTts = FlutterTts();

//   @override
//   void initState() {
//     super.initState();
//     // Replace 'assets/your_video_path.mp4' with the actual path to your video file.
//     _controller = VideoPlayerController.asset('lib/images/IMG_2457.mp4');
//     _initializeVideoPlayerFuture = _controller.initialize().then((_) {
//       // Additional processing if needed after video initialization.
//     });

//     _controller.addListener(_videoPlayerListener);
//   }

//   void _videoPlayerListener() {
//     if (_controller.value.position >= _controller.value.duration) {
//       // Video playback has reached the end, seek back to the beginning.
//       _controller.seekTo(Duration.zero);
//       // Alternatively, you can pause the video instead of seeking to reset it visually.
//       // _controller.pause();
//     }
//   }

//   @override
//   void dispose() {
//     _controller.removeListener(_videoPlayerListener);
//     _controller.dispose();
//     super.dispose();
//   }

//   void _sendMessage() async {
//     String userMessage = _textInputController.text;

//     // Create a JSON payload with the user's message
//     Map<String, dynamic> data = {"message": userMessage};

//     // URL of the backend endpoint to which the message will be sent
//     String url = 'http://35.234.108.24:8000/chat_with_chatgpt';

//     try {
//       // Send the user's message to the backend using the http package
//       http.Response response = await http.post(
//         Uri.parse(url),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(data),
//       );

//       // Check if the request was successful (status code 200-299)
//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         // Get the text response from the backend
//         String textResponse = response.body;
//         // Convert the text response to speech and play it
//         _speakResponse(textResponse);
//       } else {
//         print('Failed to send message. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error while sending message: $e');
//     }

//     // Clear the text input field after sending the message
//     _textInputController.clear();
//   }

//   Future<void> _speakResponse(String text) async {
//     await flutterTts.setLanguage("en-US");
//     await flutterTts.setSpeechRate(0.6);
//     await flutterTts.setVolume(1.0);

//     setState(() {
//       _isSpeaking = true; // Set TTS state to true (speaking)
//     });

//     await flutterTts.speak(text);

//     setState(() {
//       _isSpeaking = false; // Set TTS state to false (not speaking)
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Virtual Assistantw3e4'),
//       ),
//       backgroundColor: Color.fromARGB(255, 240, 242, 242), // Set the background color here
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _textInputController,
//                     decoration: InputDecoration(
//                       hintText: "Type your message here...",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: _sendMessage,
//                   icon: Icon(Icons.send),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Center(
//               child: FutureBuilder(
//                 future: _initializeVideoPlayerFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.done) {
//                     return Padding(
//                       padding: EdgeInsets.only(
//                           top:
//                               270.0), // Adjust the value to move the video down
//                       child: AspectRatio(
//                         aspectRatio: _controller.value.aspectRatio,
//                         child: VideoPlayer(_controller),
//                       ),
//                     );
//                   } else {
//                     return CircularProgressIndicator();
//                   }
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _sendMessage();
//           setState(() {
//             if (_controller.value.isPlaying) {
//               _controller.pause();
//             } else {
//               _controller.play();
//             }
//           });
//         },
//         child: Icon(
//           _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(VideoPlayerApp());
// }

// class VideoPlayerApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Video Player App',
//       home: VideoPlayerScreen(),
//     );
//   }
// }
