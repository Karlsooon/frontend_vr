import 'package:flutter/material.dart';

class AssistantPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Assistant'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace 'your_big_gif.gif' with the actual path of your GIF in the assets folder
            Image.asset('lib/images/assistant.gif', width: 200, height: 200),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Type here...',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.send),
                ),
                // You can handle user input using the onChanged or onSubmitted callbacks
                // For this example, I'm just printing the user input to the console.
                onChanged: (text) => print('User input: $text'),
                onSubmitted: (text) => print('User submitted: $text'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
