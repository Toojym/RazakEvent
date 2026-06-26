import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';
import '../viewmodels/home_viewmodel.dart';
import 'logo_view.dart';

import 'view_registered_participants_view.dart';
import 'event_qr_view.dart';
import 'edit_event_view.dart';

class ActiveEventsListView extends StatelessWidget {
  const ActiveEventsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(decoration: AppTheme.backgroundDecoration3),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                const RazakEventLogo(fontSize: 24),
                const SizedBox(height: 32),
                const Text(
                  'Currently Running Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primaryBlue),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: vm.allUpcomingEvents.length,
                          separatorBuilder: (context, index) => const Divider(
                            color: Colors.white24,
                            height: 1,
                            thickness: 0.5,
                          ),
                          itemBuilder: (context, index) {
                            final event = vm.allUpcomingEvents[index];
                            return _EventListItem(event: event);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final EventModel event;

  const _EventListItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              event.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Added on ${DateFormat('d/M/yyyy').format(event.date)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(width: 12),
          _IconButton(
            icon: Icons.people,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewRegisteredParticipantsView(event: event),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _IconButton(
            icon: Icons.qr_code_2,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventQrView(event: event),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _IconButton(
            icon: Icons.edit,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditEventView(event: event),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _IconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0D559E), // Dark blue from Figma
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
