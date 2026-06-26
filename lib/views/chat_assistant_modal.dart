import 'package:razak_event/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';
import '../viewmodels/chat_assistant_viewmodel.dart';
import 'event_detail_view.dart';

class ChatAssistantModal extends StatefulWidget {
  final List<EventModel> activeEvents;
  const ChatAssistantModal({super.key, required this.activeEvents});

  @override
  State<ChatAssistantModal> createState() => _ChatAssistantModalState();
}

class _ChatAssistantModalState extends State<ChatAssistantModal> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(String text, ChatAssistantViewModel vm) {
    if (text.trim().isEmpty) return;
    _controller.clear();
    vm.sendQuery(text, widget.activeEvents).then((_) => _scrollToBottom());
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatAssistantViewModel>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.primaryBlue, width: 2)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy_outlined, color: AppTheme.primaryBlue, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "RazakAI Campus Guide",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Ask about events, merit points, or food",
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: vm.messages.length + (vm.isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == vm.messages.length) {
                  return _buildThinkingBubble();
                }
                final msg = vm.messages[index];
                return _buildBubble(msg, context);
              },
            ),
          ),

          // Quick Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildChip("Free Food", vm),
                _buildChip("High Merit Points", vm),
                _buildChip("Sports & Games", vm),
                _buildChip("This Weekend", vm),
              ],
            ),
          ),

          // Text Field Bar
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Type your question here...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF242424),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (val) => _send(val, vm),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryBlue,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () => _send(_controller.text, vm),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 16, height: 16, child: CustomLoadingIndicator(strokeWidth: 2, color: AppTheme.primaryBlue)),
            SizedBox(width: 12),
            Text("RazakAI is searching campus events...", style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg, BuildContext context) {
    final isUser = msg.isUser;
    final recEvents = widget.activeEvents
        .where((e) => msg.recommendedEventIds.contains(e.eventId))
        .toList();

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryBlue : const Color(0xFF262626),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
            bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
            if (recEvents.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 8),
              const Text("Recommended Events:", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ...recEvents.map((e) => _buildMiniEventCard(e, context)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniEventCard(EventModel e, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailView(event: e)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: e.displayImageUrl != null
                  ? Image.network(e.displayImageUrl!, width: 36, height: 36, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(width: 36, height: 36, color: Colors.grey))
                  : Container(width: 36, height: 36, color: AppTheme.primaryBlue, child: const Icon(Icons.event, color: Colors.white, size: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text("${e.category} • ${e.location.isNotEmpty ? e.location : 'Campus'}", style: const TextStyle(color: Colors.white54, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, ChatAssistantViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: const Color(0xFF2A2A2A),
        side: const BorderSide(color: Color(0xFF404040)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: vm.isThinking ? null : () => _send(label, vm),
      ),
    );
  }
}
