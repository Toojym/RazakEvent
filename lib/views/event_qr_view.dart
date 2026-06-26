
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';
import '../viewmodels/event_qr_viewmodel.dart';
import 'logo_view.dart';

class EventQrView extends StatelessWidget {
  final EventModel event;

  const EventQrView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventQrViewModel(event: event),
      child: const _EventQrBody(),
    );
  }
}

class _EventQrBody extends StatefulWidget {
  const _EventQrBody();

  @override
  State<_EventQrBody> createState() => _EventQrBodyState();
}

class _EventQrBodyState extends State<_EventQrBody> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveQrCode() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: "RazakEvent_QR_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['isSuccess'] ? 'QR Code saved to gallery!' : 'Failed to save QR Code.'),
            backgroundColor: result['isSuccess'] ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save QR Code.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventQrViewModel>();
    final qrData = vm.isCrewToggle ? vm.event.crewQrCodeData : vm.event.attendeeQrCodeData;
    final maxCapacity = vm.event.maxCapacity ?? 25;

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
                  'QR Attendance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Toggle Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => vm.toggleRole(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !vm.isCrewToggle ? AppTheme.primaryBlue : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Text(
                                'Participants',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => vm.toggleRole(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: vm.isCrewToggle ? const Color(0xFF5A149B) : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Text(
                                'Crew',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Main Content Area
                Expanded(
                  child: vm.showingAttendeesList 
                      ? _buildAttendeesList(vm) 
                      : _buildQrView(vm, qrData, maxCapacity),
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
                onPressed: () {
                  if (vm.showingAttendeesList) {
                    vm.toggleListView(false);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(EventQrViewModel vm, String qrData, int maxCapacity) {
    return Column(
      children: [
        const SizedBox(height: 24),
        RepaintBoundary(
          key: _qrKey,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 240.0,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Download Button
        GestureDetector(
          onTap: _isSaving ? null : _saveQrCode,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: _isSaving 
              ? const SizedBox(
                  width: 24, height: 24, 
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                )
              : const Icon(Icons.download, color: Colors.black),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Timer
        Text(
          'QR disables in ${vm.timeRemaining}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        
        // Scanned Count
        Text(
          '${vm.totalScanned}/$maxCapacity ${vm.isCrewToggle ? 'Crew' : 'Participants'} Scanned',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        // View Attendees Button
        ElevatedButton(
          onPressed: () => vm.toggleListView(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: const Text(
            'View Attendees',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAttendeesList(EventQrViewModel vm) {
    return Column(
      children: [
        Expanded(
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
              : vm.filteredAttendees.isEmpty
                  ? const Center(
                      child: Text(
                        'No attendees scanned yet.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      itemCount: vm.filteredAttendees.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.white24,
                        height: 1,
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        final attendee = vm.filteredAttendees[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  attendee.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                attendee.matric,
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
        
        // Return Button
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => vm.toggleListView(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA01515), // Red button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Return',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
