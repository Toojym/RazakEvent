import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/event_model.dart';
import 'api_keys.dart';

class AiService {
  Future<Map<String, dynamic>?> extractEventInfoFromPoster(Uint8List imageBytes) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: geminiApiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.2,
        ),
      );

      const prompt = '''
You are an AI assistant for a UTM college event app called RazakEvent.
Analyze this event poster/flyer image and extract any event details.
Return a valid JSON object with exactly these keys:
{
  "title": "the extracted event name or catchy title",
  "description": "a clean, engaging 2-3 sentence summary of the event details, objectives, or activities",
  "location": "the venue or location (e.g. Dewan KTR, Court KTR, etc.) or empty string",
  "category": "Must be exactly one of: Sports, Academic, Arts, Cultural, Other",
  "attendeeMerit": 1,
  "crewMerit": 3
}
If merit points are not explicitly stated on the poster, estimate reasonable defaults (e.g., 1-3 for attendees, 3-5 for crew).
''';

      final response = await model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ]);

      if (response.text != null && response.text!.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(response.text!);
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

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
