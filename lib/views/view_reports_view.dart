import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../viewmodels/view_reports_viewmodel.dart';
import 'logo_view.dart';

class ViewReportsView extends StatelessWidget {
  const ViewReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ViewReportsViewModel(),
      child: const _ViewReportsBody(),
    );
  }
}

class _ViewReportsBody extends StatelessWidget {
  const _ViewReportsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ViewReportsViewModel>();
    final reports = vm.reports;

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
                  'View Reports',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 48), // Spacing before the list
                
                // Divider above list
                const Divider(color: Colors.white24, height: 1, thickness: 1),
                
                // Reports List
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
                      : reports.isEmpty
                          ? const Center(child: Text('No reports uploaded yet.', style: TextStyle(color: Colors.white54)))
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: reports.length,
                              separatorBuilder: (context, index) => const Divider(
                                color: Colors.white24,
                                height: 1,
                                thickness: 1,
                              ),
                              itemBuilder: (context, index) {
                                final reportDetails = reports[index];
                                final rName = '${reportDetails.report.eventName} (${reportDetails.report.type})';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          rName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        reportDetails.statusText,
                                        style: TextStyle(
                                          color: reportDetails.statusColor,
                                          fontSize: 9,
                                        ),
                                      ),
                            const SizedBox(width: 12),
                            _IconButton(
                              icon: Icons.visibility_outlined,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('View Report coming soon!')),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            _IconButton(
                              icon: Icons.edit_outlined,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Edit Report coming soon!')),
                                );
                              },
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
