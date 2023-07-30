// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   // final String apiUrl = 'http://your_domain_or_ip/myapp/uneeq_event/'; // Replace with the correct URL of your Django server

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('UneeQ Example'),
//         ),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: sendMessageToServer,
//             child: Text('Send UneeQ Message'),
//           ),
//         ),
//       ),
//     );
//   }

//   void sendMessageToServer() async {
//     final options = {
//       'url': 'https://api.us.uneeq.io',
//       'conversationId': '3bcd98e8-4b77-4968-803f-2ade16207d4f',
//       'playWelcome': false,
//       'sendLocalVideo': false,
//       'sendLocalAudio': true,
//     };

//     // Replace 'your_api_token_here' with your actual UneeQ API token
//     final String token = 'E21B51EB-F3C3-F2B3-156D-83D74385198A';

//     // Convert the options to JSON
//     String jsonOptions = jsonEncode(options);

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonOptions,
//       );

//       if (response.statusCode == 200) {
//         print('Message sent successfully!');
//         print('Response: ${response.body}');
//       } else {
//         print('Failed to send message. Status code: ${response.statusCode}');
//         print('Response: ${response.body}');
//       }
//     } catch (e) {
//       print('Error sending message: $e');
//     }
//   }
// }
