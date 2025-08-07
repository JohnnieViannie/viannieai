import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatOverlay extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  Future<String> getAIResponse(String input) async {
    final apiKey = "YOUR_OPENAI_API_KEY";

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4",
        "messages": [{"role": "user", "content": input}]
      }),
    );

    final decoded = jsonDecode(response.body);
    return decoded['choices'][0]['message']['content'];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: 300,
        color: Colors.white,
        child: Column(
          children: [
            Text("AI Assistant", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _controller,
              onSubmitted: (value) async {
                final reply = await getAIResponse(value);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    content: Text(reply),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
