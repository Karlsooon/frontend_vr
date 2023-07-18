import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ResultPage extends StatefulWidget {
  final String result;

  const ResultPage({Key? key, required this.result}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  FlutterTts flutterTts = FlutterTts();
  TextEditingController _chatController = TextEditingController();
  List<String> chatHistory = [];

  @override
  void initState() {
    super.initState();
    speakResult();
    addResultToChatHistory();
  }

  Future<void> speakResult() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(0.6);
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.speak(widget.result);
  }

  void addResultToChatHistory() {
    if (widget.result.isNotEmpty) {
      setState(() {
        chatHistory.add("AR Lense: ${widget.result}");
      });
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    _chatController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: chatHistory.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(chatHistory[index]),
                  );
                },
              ),
            ),
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
        ],
      ),
    );
  }
}
