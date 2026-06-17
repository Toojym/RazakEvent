import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/upload_report_viewmodel.dart';
import 'logo_view.dart';

class UploadReportView extends StatelessWidget {
  const UploadReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UploadReportViewModel(),
      child: const _UploadReportViewBody(),
    );
  }
}

class _UploadReportViewBody extends StatefulWidget {
  const _UploadReportViewBody();

  @override
  State<_UploadReportViewBody> createState() => _UploadReportViewBodyState();
}

class _UploadReportViewBodyState extends State<_UploadReportViewBody> {
  EventModel? _selectedEvent;
  String? _selectedReportType;

  final List<String> _reportTypes = ['Financial', 'Program'];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final vmUpload = context.watch<UploadReportViewModel>();
    final activeEvents = vm.organizerUpcomingEvents;

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
                  'Upload Report',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 48),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Event Name Dropdown
                        _FormRow(
                          label: 'Event Name',
                          child: _PillDropdown<EventModel>(
                            value: _selectedEvent,
                            hint: 'Select Event',
                            items: activeEvents.map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e.title,
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedEvent = val),
                          ),
                        ),
                        
                        // Upload Report Box
                        _FormRow(
                          label: 'Upload Report',
                          alignTop: true,
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Media Upload feature coming soon!')),
                              );
                            },
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: vmUpload.selectedFile != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          vmUpload.selectedFile!.name,
                                          style: const TextStyle(color: Colors.black, fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : const Icon(Icons.upload_outlined, color: Colors.black),
                              ),
                            ),
                          ),
                        ),

                        // Report Type Dropdown
                        _FormRow(
                          label: 'Report Type',
                          child: _PillDropdown<String>(
                            value: _selectedReportType,
                            hint: 'Select Type',
                            items: _reportTypes.map((t) {
                              return DropdownMenuItem(
                                value: t,
                                child: Text(t, style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedReportType = val),
                          ),
                        ),
                        
                        const SizedBox(height: 120), // Spacer before buttons
                        
                        // Action Buttons
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: vmUpload.isLoading ? null : () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Media Upload feature coming soon!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E5BB8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: vmUpload.isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Upload Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA01515),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
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

// ── Shared UI Components ─────────────────────────────────────────────

class _FormRow extends StatelessWidget {
  final String label;
  final Widget child;
  final bool alignTop;

  const _FormRow({required this.label, required this.child, this.alignTop = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _PillDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _PillDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black, fontSize: 12),
          hint: Text(hint, style: const TextStyle(color: Colors.black54, fontSize: 10)),
          value: value,
          icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.grey, size: 16),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
