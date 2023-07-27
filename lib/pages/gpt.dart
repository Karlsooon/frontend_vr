import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatefulWidget {
  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _chatMessages = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Chat with Object'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  return _chatMessages[index];
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration:
                          InputDecoration(hintText: 'Type a message...'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      String message = _messageController.text.trim();
                      if (message.isNotEmpty) {
                        _sendMessage(message);
                        _messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _chatMessages.add(ChatMessage(sender: 'You', text: message));
    });

    try {
      var response = await http.post(
        Uri.parse(
            'http://127.0.0.1:8000//chat_with_chatgpt'), // Replace with your backend URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        String chatGptResponse = responseBody['response'];

        setState(() {
          _chatMessages
              .add(ChatMessage(sender: 'Object', text: chatGptResponse));
        });
      } else {
        setState(() {
          _chatMessages.add(ChatMessage(
              sender: 'Object', text: 'Error: ${response.statusCode}'));
        });
      }
    } catch (e) {
      setState(() {
        _chatMessages.add(ChatMessage(sender: 'Object', text: 'Error: $e'));
      });
    }
  }
}

class ChatMessage extends StatelessWidget {
  final String sender;
  final String text;

  ChatMessage({required this.sender, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment:
            sender == 'You' ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: sender == 'You' ? Colors.blue : Colors.green,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}
