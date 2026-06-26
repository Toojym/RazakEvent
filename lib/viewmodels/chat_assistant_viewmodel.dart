import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/ai_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<String> recommendedEventIds;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.recommendedEventIds = const [],
  });
}

class ChatAssistantViewModel extends ChangeNotifier {
  final AiService _aiService = AiService();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I am RazakAI, your campus student assistant. Ask me anything about upcoming events, free food, or merit points!",
      isUser: false,
    ),
  ];
  bool _isThinking = false;

  List<ChatMessage> get messages => _messages;
  bool get isThinking => _isThinking;

  Future<void> sendQuery(String prompt, List<EventModel> activeEvents) async {
    if (prompt.trim().isEmpty || _isThinking) return;

    _messages.add(ChatMessage(text: prompt.trim(), isUser: true));
    _isThinking = true;
    notifyListeners();

    final result = await _aiService.recommendEvents(
      userPrompt: prompt.trim(),
      events: activeEvents,
    );

    _isThinking = false;

    if (result != null && result['response'] != null) {
      final responseText = result['response'].toString();
      final recIds = (result['recommendedEventIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      _messages.add(ChatMessage(
        text: responseText,
        isUser: false,
        recommendedEventIds: recIds,
      ));
    } else {
      _messages.add(ChatMessage(
        text: "Sorry, I had trouble connecting to the campus catalog. Please try asking again!",
        isUser: false,
      ));
    }
    notifyListeners();
  }
}
