import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Replace this with your PC's IPv4 address.
  // Example: http://192.168.1.5:3000
  static const String _backendUrl = 'http://192.168.0.108:3000/parse-request';

  static Future<Map<String, dynamic>> parseRequest(
    String userInput,
    String userCity,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userInput': userInput, 'userCity': userCity}),
      );

      if (response.statusCode != 200) {
        throw Exception('Backend returned status ${response.statusCode}');
      }

      final parsed = jsonDecode(response.body) as Map<String, dynamic>;

      if (parsed['budget'] == null ||
          parsed['budget'].toString().trim().isEmpty) {
        parsed['budget'] = 'Medium';
      }

      return parsed;
    } catch (e) {
      return {
        'service': 'General Service',
        'city': userCity,
        'location': userCity,
        'time': 'Flexible',
        'urgency': 'Medium',
        'budget': 'Medium',
        'confidence': 60,
        'language': 'Unknown',
        'reasoning': 'Unable to connect to the AI service',
        'agentLog': [],
      };
    }
  }
}
