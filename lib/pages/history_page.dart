import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final String historyParagraph;

  const HistoryPage({Key? key, required this.historyParagraph}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Paragraph'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            historyParagraph,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
