import 'package:razak_event/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';
import '../viewmodels/admin_all_paperwork_viewmodel.dart';
import 'logo_view.dart';

/// Admin page that lists all events that have uploaded paperwork.
/// Clicking on an event launches the paperwork document.
class AdminAllPaperworkView extends StatelessWidget {
  const AdminAllPaperworkView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminAllPaperworkViewModel(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminAllPaperworkViewModel>();
    final events = vm.paperworkEvents;

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
                // ── Top bar ──
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // ── Logo & subtitle ──
                const SizedBox(height: 4),
                const Center(child: RazakEventLogo(fontSize: 24)),
                const SizedBox(height: 32),
                const Text(
                  'All Paperwork',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Events list ──
                Expanded(
                  child: vm.isLoading
                      ? const Center(
                          child: CustomLoadingIndicator(color: AppTheme.primaryBlue),
                        )
                      : events.isEmpty
                          ? const Center(
                              child: Text(
                                'No paperwork uploaded yet.',
                                style: TextStyle(color: Colors.white54, fontSize: 14),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              itemCount: events.length,
                              separatorBuilder: (_, _) => const Divider(
                                color: Colors.white24,
                                height: 1,
                                thickness: 0.5,
                              ),
                              itemBuilder: (context, index) {
                                final item = events[index];
                                return _EventPaperworkRow(item: item);
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
class _EventPaperworkRow extends StatelessWidget {
  final EventModel item;
  const _EventPaperworkRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final url = item.paperworkUrl;
        if (url != null && await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open paperwork document.')),
            );
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Event info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.location,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Open icon
            const Icon(Icons.open_in_new, color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }
}

