import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';
import '../viewmodels/event_detail_viewmodel.dart';
import 'logo_view.dart';

class EventDetailView extends StatelessWidget {
  final EventModel event;

  const EventDetailView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventDetailViewModel(event: event),
      child: const _EventDetailBody(),
    );
  }
}

class _EventDetailBody extends StatelessWidget {
  const _EventDetailBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventDetailViewModel>();

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration2,
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────
              const SizedBox(height: 16),
              const Center(child: RazakEventLogo(fontSize: 24)),
              const SizedBox(height: 4),
              const Text(
                'Event Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),

              // ── Scrollable Content ──────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Top Row (Poster and Details)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Poster
                          Expanded(
                            flex: 4,
                            child: _PosterImage(event: vm.event),
                          ),
                          const SizedBox(width: 16),
                          // Details
                          Expanded(
                            flex: 5,
                            child: _EventDetailsList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Slots Section
                      Row(
                        children: [
                          Expanded(
                            child: _SlotCard(
                              title: 'Filled\nSlots',
                              value: vm.filledSlots.toString(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SlotCard(
                              title: 'Empty\nSlots',
                              value: vm.emptySlots.toString(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SlotCard(
                        title: 'Available\nPositions',
                        value: vm.availablePositions.toString(),
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 40),

                      // Action Buttons
                      if (vm.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: vm.isLoading
                              ? null
                              : () {
                                  if (vm.isRegistered) {
                                    _showUnregisterConfirmDialog(context, vm);
                                  } else {
                                    vm.register();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: vm.isRegistered 
                                ? Colors.transparent 
                                : const Color(0xFF1E5BB8), // Darker blue matching screenshot
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: vm.isRegistered 
                                  ? const BorderSide(color: Colors.redAccent, width: 1.5)
                                  : BorderSide.none,
                            ),
                          ),
                          child: vm.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  vm.isRegistered ? 'Cancel Registration' : 'Register',
                                  style: TextStyle(
                                    color: vm.isRegistered ? Colors.redAccent : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA01515), // Darker red matching screenshot
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnregisterConfirmDialog(BuildContext context, EventDetailViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Cancel Registration', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to cancel your registration for this event?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              vm.unregister();
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _PosterImage extends StatelessWidget {
  final EventModel event;

  const _PosterImage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 0.5),
        image: event.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(event.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: event.imageUrl == null
          ? _PlaceholderPoster(event: event)
          : null,
    );
  }
}

class _PlaceholderPoster extends StatelessWidget {
  final EventModel event;

  const _PlaceholderPoster({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
        ),
      ),
      child: Center(
        child: Text(
          event.category,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ),
    );
  }
}

class _EventDetailsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventDetailViewModel>();
    final event = vm.event;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          event.description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.4,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        _DetailRow(label: 'DATE', value: vm.formattedDate),
        _DetailRow(label: 'DURATION', value: vm.duration),
        _DetailRow(label: 'START TIME', value: vm.startTime),
        _DetailRow(label: 'END TIME', value: vm.endTime),
        _DetailRow(label: 'LOCATION', value: event.location),
        _DetailRow(label: 'STATUS', value: vm.status),
        _DetailRow(label: 'FEE', value: vm.fee),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              '$label :',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isFullWidth;

  const _SlotCard({
    required this.title,
    required this.value,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.2,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w300,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
