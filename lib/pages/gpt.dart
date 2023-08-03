import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add the initial message when the page loads
    _chatMessages.add(ChatMessage(
      sender: 'Object',
      text: 'Hi you can ask any question about me',
      isUser: false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 213, 211, 211),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('lib/images/chat_icon.png'),
            ),
            SizedBox(width: 10),
            Text(
              'Object',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Hide the keyboard when the user taps outside the input field
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Colors.white, // Set the background color to white
          child: Column(
            children: [
              Expanded(child: _buildChatMessages()),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _chatMessages.length,
      itemBuilder: (context, index) {
        return _chatMessages[index];
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Color.fromARGB(255, 255, 255, 255),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  border: InputBorder.none,
                ),
              ),
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
    );
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _chatMessages.add(ChatMessage(sender: 'You', text: message, isUser: true));
    });

    try {
      var response = await http.post(
        Uri.parse('http://35.234.108.24:8000/chat_with_chatgpt'),
        // Replace with your backend URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        String chatGptResponse = responseBody['response'];

        setState(() {
          _chatMessages.add(ChatMessage(
            sender: 'Object',
            text: chatGptResponse,
            isUser: false, // Set isUser to false for response messages
          ));
        });
      } else {
        setState(() {
          _chatMessages.add(ChatMessage(
            sender: 'Object',
            text: 'Error: ${response.statusCode}',
            isUser: false, // Set isUser to false for error messages
          ));
        });
      }
    } catch (e) {
      setState(() {
        _chatMessages.add(ChatMessage(
          sender: 'Object',
          text: 'Error: $e',
          isUser: false, // Set isUser to false for error messages
        ));
      });
    }

    // Automatically scroll to the end after adding the message
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String sender;
  final String text;
  final bool isUser;

  const ChatMessage({required this.sender, required this.text, this.isUser = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        // Align the chat bubble to the right or left
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser ? Color.fromARGB(255, 48, 162, 255) : Color.fromARGB(255, 214, 218, 214),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end, // Align the icon to the bottom
            children: [
              if (!isUser) Icon(Icons.account_circle, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
