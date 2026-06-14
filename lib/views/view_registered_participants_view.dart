import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';
import '../viewmodels/view_registered_participants_viewmodel.dart';
import 'logo_view.dart';

class ViewRegisteredParticipantsView extends StatelessWidget {
  final EventModel event;

  const ViewRegisteredParticipantsView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ViewRegisteredParticipantsViewModel(event: event),
      child: const _ViewRegisteredParticipantsBody(),
    );
  }
}

class _ViewRegisteredParticipantsBody extends StatelessWidget {
  const _ViewRegisteredParticipantsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ViewRegisteredParticipantsViewModel>();
    final event = vm.event;
    final participants = vm.participants;
    final maxSlots = event.maxCapacity ?? 15;
    final registeredCount = participants.length;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(decoration: AppTheme.backgroundDecoration3),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                const SizedBox(height: 16),
                const Center(child: RazakEventLogo(fontSize: 24)),
                const SizedBox(height: 4),
                const Text(
                  'View Participants',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Event Details
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '$registeredCount/$maxSlots Registered Participants',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Divider above list
                const Divider(color: Colors.white24, height: 1, thickness: 1),
                
                // Participants List
                Expanded(
                  child: vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                        )
                      : participants.isEmpty
                          ? const Center(
                              child: Text(
                                'No registered participants yet.',
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: participants.length,
                              separatorBuilder: (context, index) => const Divider(
                                color: Colors.white24,
                                height: 1,
                                thickness: 1,
                              ),
                              itemBuilder: (context, index) {
                                final participant = participants[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          participant.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        participant.matric,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          
          // Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
