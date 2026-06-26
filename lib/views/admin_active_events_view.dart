import 'package:razak_event/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';
import '../viewmodels/admin_events_viewmodel.dart';
import 'logo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'view_registered_participants_view.dart';
import 'edit_event_view.dart';

/// Admin view – scrollable list of currently running / upcoming events.
/// Each row shows the event name, "Added on dd/M/yyyy", and two blue
/// action buttons (functionality to be added later).
class AdminActiveEventsView extends StatelessWidget {
  const AdminActiveEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminEventsViewModel(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminEventsViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          // ── Background ──────────────────────────────────────
          Positioned.fill(
            child: Container(decoration: AppTheme.backgroundDecoration4),
          ),

          // ── Content ─────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 4),
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
                          child: CustomLoadingIndicator(
                              color: AppTheme.primaryBlue),
                        )
                      : vm.activeEvents.isEmpty
                          ? const Center(
                              child: Text(
                                'No active events',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 14),
                              ),
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: vm.activeEvents.length,
                              separatorBuilder: (context, index) => const Divider(
                                color: Colors.white24,
                                height: 1,
                                thickness: 0.5,
                              ),
                              itemBuilder: (context, index) {
                                final event = vm.activeEvents[index];
                                return _ActiveEventRow(event: event);
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

// ── Single event row ────────────────────────────────────────────────────
class _ActiveEventRow extends StatelessWidget {
  final EventModel event;
  const _ActiveEventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Event name
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
          // "Added on" date
          Text(
            'Added on ${DateFormat('d/M/yyyy').format(event.date)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(width: 12),
          // Blue action buttons (functionality TBD)
          _BlueIconButton(
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
          _BlueIconButton(
            icon: Icons.folder_shared,
            onPressed: () async {
              final url = event.paperworkUrl;
              if (url != null && url.trim().isNotEmpty) {
                try {
                  await launchUrl(Uri.parse(url.trim()), mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open paperwork document.')),
                    );
                  }
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No paperwork document uploaded for this event.')),
                  );
                }
              }
            },
          ),
          const SizedBox(width: 8),
          _BlueIconButton(
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

// ── Reusable blue icon button ───────────────────────────────────────────
class _BlueIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _BlueIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0D559E),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
