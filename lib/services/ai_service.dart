import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/event_model.dart';
import 'api_keys.dart';

class AiService {
  Future<Map<String, dynamic>?> recommendEvents({
    required String userPrompt,
    required List<EventModel> events,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: geminiApiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.4,
        ),
      );

      final eventsListJson = events
          .map((e) => {
                'eventId': e.eventId,
                'title': e.title,
                'description': e.description,
                'category': e.category,
                'location': e.location,
                'attendeeMeritPoints': e.attendeeMeritPoints,
                'date': e.date.toIso8601String(),
              })
          .toList();

      final fullPrompt = '''
You are RazakAI, a helpful campus student assistant for UTM college students.
Here is the list of currently available upcoming events in JSON format:
${jsonEncode(eventsListJson)}

The student asked: "$userPrompt"

Analyze the available events and recommend the best matches.
Return a valid JSON object with exactly these keys:
{
  "response": "A helpful conversational message (2-4 sentences) answering the student's prompt and highlighting why the recommended events are great.",
  "recommendedEventIds": ["id_of_event_1", "id_of_event_2"]
}
If no events match well, return a response explaining that and return an empty list for "recommendedEventIds".
IMPORTANT: Do NOT use any emojis anywhere in your response text.
''';

      final response = await model.generateContent([Content.text(fullPrompt)]);

      if (response.text != null && response.text!.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(response.text!);
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
