import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'home_page_camera.dart';

class GalleryAccess extends StatefulWidget {
  final File galleryFile;
  const GalleryAccess({Key? key, required this.galleryFile}) : super(key: key);

  @override
  State<GalleryAccess> createState() => _GalleryAccessState();
}

class _GalleryAccessState extends State<GalleryAccess> {
  static const String openAIApiKey = 'YOUR_OPENAI_API_KEY';

  FlutterTts flutterTts = FlutterTts();
  bool isPlayerOn = false;
  var isResult = false;
  var isLoading = false;
  String? resultData;
  TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = []; // Move _messages list here

  @override
  void initState() {
    super.initState();
    _getResultFromBackend();
  }

  Future<void> _getResultFromBackend() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Create a multipart request for sending the image
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://35.234.108.24:8000/process_image'),
      );

      // Add the image file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          widget.galleryFile.path,
        ),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        setState(() {
          isLoading = false;
          resultData = responseBody;
        });
        speakResult(); // Speak the result when it's received
      } else {
        setState(() {
          isLoading = false;
          resultData = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        resultData = 'Error: $e';
      });
    }
  }

  Future<void> speakResult() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(0.7);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(resultData ?? '');
  }

 Future<void> _sendMessage(String message) async {
    // Add the user message to the chat
    setState(() {
      _messages.add(ChatMessage(sender: 'You', text: message));
    });

    try {
      // Call the OpenAI API to get the response
      var response = await http.post(
        Uri.parse('https://api.openai.com/v1/engines/davinci/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIApiKey',
        },
        body: jsonEncode({
          'prompt': message,
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        String chatGptResponse = responseBody['choices'][0]['text'];

        // Add the ChatGPT response to the chat
        setState(() {
          _messages.add(ChatMessage(sender: 'Object', text: chatGptResponse));
        });
      } else {
        // Handle API error
        setState(() {
          _messages.add(ChatMessage(sender: 'Object', text: 'Error: ${response.statusCode}'));
        });
      }
    } catch (e) {
      // Handle exception
      setState(() {
        _messages.add(ChatMessage(sender: 'Object', text: 'Error: $e'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(widget.galleryFile),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
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
                                builder: (context) => ARKitExample(
                                  func: print,
                                ),
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
                  Transform.scale(
                    scale: 0.5,
                    child: isLoading
                        ? Image.asset(
                            'lib/images/spinner.gif',
                          )
                        : Container(),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Material(
                        color: Color(0xFF462B9C),
                        borderRadius: BorderRadius.circular(20.0),
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
                            color: Colors.white,
                          ),
                          iconSize: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isResult
                ? Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Container(
                      width: 430,
                      height: 600,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Color(0xff462b9c),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Result',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isResult = false;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.close_outlined,
                                        color: Colors.white,
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
                                color: Colors.white,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (context) => ChatInterface(),
                                  ),
                                );
                              },
                              child: Text('Chat with Object'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class ChatInterface extends StatefulWidget {
  @override
  _ChatInterfaceState createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  List<ChatMessage> _messages = [];
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with an Object'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ChatMessageWidget(
                    sender: _messages[index].sender,
                    text: _messages[index].text,
                  );
                },
              ),
            ),
            // Input field for typing messages
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (message) {
                      if (message.trim().isNotEmpty) {
                        _sendMessage(message);
                      }
                    },
                    // ... TextField properties ...
                  ),
                ),
                IconButton(
                  onPressed: () {
                    String message = _textController.text.trim();
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                      _textController.clear();
                    }
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String message) {
    // Add the user message to the chat
    setState(() {
      _messages.add(ChatMessage(sender: 'You', text: message));
    });

    // Send the message to ChatGPT backend and get the response
    // Replace this with your code to interact with the backend
    String chatGptResponse = 'ChatGPT Response';

    // Add the ChatGPT response to the chat
    setState(() {
      _messages.add(ChatMessage(sender: 'Object', text: chatGptResponse));
    });
  }
}

class ChatMessage {
  final String sender;
  final String text;

  ChatMessage({required this.sender, required this.text});
}

class ChatMessageWidget extends StatelessWidget {
  final String sender;
  final String text;

  ChatMessageWidget({required this.sender, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment:
            sender == 'You' ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: sender == 'You' ? Colors.blue : Colors.green,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
