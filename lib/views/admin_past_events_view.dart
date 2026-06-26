import 'package:razak_event/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';
import '../viewmodels/admin_events_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'logo_view.dart';

/// Admin view – scrollable list of past (already finished) events.
/// Each row shows the event name, a "Uploaded X days early/late" label
/// (relative to event start date), and two blue action buttons
/// (functionality to be added later).
class AdminPastEventsView extends StatelessWidget {
  const AdminPastEventsView({super.key});

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
                  'Past Events',
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
                      : vm.pastEvents.isEmpty
                          ? const Center(
                              child: Text(
                                'No past events',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 14),
                              ),
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: vm.pastEvents.length,
                              separatorBuilder: (context, index) => const Divider(
                                color: Colors.white24,
                                height: 1,
                                thickness: 0.5,
                              ),
                              itemBuilder: (context, index) {
                                final event = vm.pastEvents[index];
                                final timingLabel =
                                    vm.getPaperworkTimingLabel(event);
                                return _PastEventRow(
                                  event: event,
                                  timingLabel: timingLabel,
                                );
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

// ── Single past-event row ───────────────────────────────────────────────
class _PastEventRow extends StatelessWidget {
  final EventModel event;
  final String? timingLabel;

  const _PastEventRow({
    required this.event,
    required this.timingLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colour based on early / late / null
    Color timingColor;
    if (timingLabel == null) {
      timingColor = Colors.white38;
    } else if (timingLabel!.contains('late')) {
      timingColor = const Color(0xFFFF6B6B); // soft red
    } else {
      timingColor = const Color(0xFF81C784); // soft green
    }

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
          // Paperwork timing label
          Text(
            timingLabel ?? 'No paperwork',
            style: TextStyle(
              color: timingColor,
              fontSize: 10,
              fontWeight: FontWeight.w300,
              fontStyle:
                  timingLabel == null ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          const SizedBox(width: 12),
          // View paperwork button
          _BlueIconButton(
            icon: Icons.visibility,
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
