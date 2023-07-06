import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> generateHistoricalText(String inputWords) async {
  final apiUrl = 'https://api.openai.com/v1/engines/davinci-codex/completions';
  final apiKey = 'YOUR_API_KEY'; // Replace with your actual API key

  final prompt =
      "In the history of the world, these words were significant: \"$inputWords\". ";

  final requestBody = json.encode({
    'prompt': prompt,
    'max_tokens': 50, // Adjust the number of tokens as per your requirement
    'temperature':
        0.7, // Adjust the temperature to control the randomness of the output
  });

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: requestBody,
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    final choices = responseBody['choices'];
    if (choices.isNotEmpty) {
      final generatedText = choices[0]['text'];
      return generatedText;
    }
  }

  return 'Failed to generate historical text.';
}
