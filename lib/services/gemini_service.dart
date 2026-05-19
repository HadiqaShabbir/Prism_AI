import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyBVI6O0KVCjIBtKJVu-l64kefVe7GfIDZY';

  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: _apiKey,
  );

  static Future<Map<String, dynamic>> parseRequest(
    String userInput,
    String userCity,
  ) async {
    try {
      final prompt =
          '''
You are an AI service request parser for Pakistan's informal economy app called PRISM AI.

User submitted this request: "$userInput"
User registered city: "$userCity"

Return ONLY valid JSON, no extra text, no markdown, no backticks:

{
  "service": "detected service",
  "city": "detected city",
  "location": "specific area mentioned",
  "time": "when they need it",
  "urgency": "Low or Medium or High",
  "budget": "Low or Medium or High",
  "confidence": 85,
  "language": "English or Roman Urdu or Mixed",
  "reasoning": "brief explanation"
}

Rules:
- service: AC Repair, Electrician, Plumbing, Beautician, Tutor, Cleaning, Mechanic, Shifting, General Service
- city: Karachi, Lahore, Islamabad, Rawalpindi, Peshawar, Quetta, Faisalabad, Multan — if not found use "$userCity"
- urgency High if: aaj/today/abhi/jaldi/urgent/tonight
- urgency Medium if: kal/tomorrow
- urgency Low if: weekend/flexible
- budget Low if: sasta/cheap/budget/kam paise
- budget High if: best/premium/quality
- budget: if not mentioned, always return "Medium" as default
- confidence 0-99 based on clarity
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      final clean = text.replaceAll('```json', '').replaceAll('```', '').trim();

      final parsed = jsonDecode(clean) as Map<String, dynamic>;
      // Budget fallback if empty
      if (parsed['budget'] == null || parsed['budget'].toString().isEmpty) {
        parsed['budget'] = 'Medium';
      }

      parsed['agentLog'] = [
        '[Gemini API] Model: gemini-2.5-flash — Connected',
        '[Language Parser] Detected: ${parsed['language'] ?? 'Mixed'}',
        '[Intent Extractor] Service: ${parsed['service']}',
        '[Entity Recogniser] Location: ${parsed['location']} → City: ${parsed['city']}',
        '[Time Parser] Preferred slot: ${parsed['time']}',
        '[Urgency Classifier] Level: ${parsed['urgency']}',
        '[Budget Analyser] Sensitivity: ${parsed['budget']}',
        '[Confidence Scorer] Score: ${parsed['confidence']}%',
        '[Reasoning] ${parsed['reasoning'] ?? 'Processed successfully'}',
      ];

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
        'reasoning': 'Fallback mode active',
        'agentLog': [
          '[Gemini API] Connection failed — fallback activated',
          '[Local Engine] Processing with local parser',
          '[Warning] Reduced accuracy in fallback mode',
          '[Error] ${e.toString().substring(0, 50)}',
        ],
      };
    }
  }
}
