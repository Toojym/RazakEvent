import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/create_event_viewmodel.dart';

import 'logo_view.dart';
import 'package:intl/intl.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  final _formKey = GlobalKey<FormState>();
  
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final durationController = TextEditingController(text: '1');
  final slotsController = TextEditingController();
  final feeRinggitController = TextEditingController();
  final feeCentsController = TextEditingController();
  final attendeeMeritController = TextEditingController();
  final crewMeritController = TextEditingController();
  
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? selectedCategory;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    durationController.dispose();
    slotsController.dispose();
    feeRinggitController.dispose();
    feeCentsController.dispose();
    attendeeMeritController.dispose();
    crewMeritController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        if (isStart) {
          startTime = time;
        } else {
          endTime = time;
        }
      });
    }
  }

  void _submit(CreateEventViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;
    
    if (selectedDate == null || startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date and start time.")),
      );
      return;
    }

    final finalDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      startTime!.hour,
      startTime!.minute,
    );

    int durationDays = 1;
    if (durationController.text.isNotEmpty) {
      durationDays = int.tryParse(durationController.text) ?? 1;
    }
    if (durationDays < 1) durationDays = 1;

    DateTime? finalEndTime;
    if (endTime != null) {
      finalEndTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        endTime!.hour,
        endTime!.minute,
      ).add(Duration(days: durationDays - 1));

      if (finalEndTime.isBefore(finalDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event End Time cannot be before Start Time.")),
        );
        return;
      }
    }

    int? slots;
    if (slotsController.text.isNotEmpty) {
      slots = int.tryParse(slotsController.text);
    }

    int? attendeeMerits = int.tryParse(attendeeMeritController.text);
    int? crewMerits = int.tryParse(crewMeritController.text);

    if (attendeeMerits == null || crewMerits == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid merit points for attendees and crew.")),
      );
      return;
    }

    final errorMessage = await viewModel.submitEvent(
      title: titleController.text,
      description: descriptionController.text,
      date: finalDateTime,
      endDate: finalEndTime,
      location: locationController.text,
      attendeeMeritPoints: attendeeMerits,
      crewMeritPoints: crewMerits,
      maxCapacity: slots,
      category: selectedCategory ?? 'Other',
    );

    if (!mounted) return;

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event Created Successfully!")),
      );
      // Reset form or navigate away
      _formKey.currentState?.reset();
      setState(() {
        selectedDate = null;
        startTime = null;
        endTime = null;
        selectedCategory = null;
        titleController.clear();
        descriptionController.clear();
        locationController.clear();
        slotsController.clear();
        feeRinggitController.clear();
        feeCentsController.clear();
        attendeeMeritController.clear();
        crewMeritController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateEventViewModel(),
      child: Consumer<CreateEventViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E0B1A), // Dark purple/pink top left
                    Color(0xFF000000), // Black middle
                    Color(0xFF001530), // Dark blue bottom right
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // ── Header ──────────────────────────────────────────
                    const SizedBox(height: 16),
                    const Center(child: RazakEventLogo(fontSize: 24)),
                    const SizedBox(height: 4),
                    const Text(
                      'Add Event',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Form Content ────────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // ── AI Auto-Fill OCR Banner ─────────────────────
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8E2DE2).withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: viewModel.isAiScanning ? null : () async {
                                      final data = await viewModel.scanPosterWithAi();
                                      if (!context.mounted) return;
                                      if (data != null) {
                                        if (data['title'] != null && data['title'].toString().isNotEmpty) {
                                          titleController.text = data['title'].toString();
                                        }
                                        if (data['description'] != null && data['description'].toString().isNotEmpty) {
                                          descriptionController.text = data['description'].toString();
                                        }
                                        if (data['location'] != null && data['location'].toString().isNotEmpty) {
                                          locationController.text = data['location'].toString();
                                        }
                                        if (data['category'] != null) {
                                          setState(() {
                                            selectedCategory = data['category'].toString();
                                          });
                                        }
                                        if (data['attendeeMerit'] != null) {
                                          attendeeMeritController.text = data['attendeeMerit'].toString();
                                        }
                                        if (data['crewMerit'] != null) {
                                          crewMeritController.text = data['crewMerit'].toString();
                                        }

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Event details extracted! You can edit them before saving."),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else if (!viewModel.isAiScanning) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Could not extract details from image. Please enter manually."),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (viewModel.isAiScanning) ...[
                                            const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              "Scanning Poster OCR...",
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                                            ),
                                          ] else ...[
                                            const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                                            const SizedBox(width: 10),
                                            const Text(
                                              "Auto-Fill from Poster (AI OCR)",
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _FormRow(
                                label: 'Event Name',
                                child: _PillTextField(controller: titleController),
                              ),
                              _FormRow(
                                label: 'Event Description',
                                child: _PillTextField(controller: descriptionController),
                              ),
                              _FormRow(
                                label: 'Event Date',
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _pickDate,
                                        child: _PillContainer(
                                          child: Text(
                                            selectedDate != null 
                                                ? DateFormat('dd/MM/yyyy').format(selectedDate!) 
                                                : '',
                                            style: const TextStyle(color: Colors.black, fontSize: 13),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: _pickDate,
                                      child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                                    ),
                                  ],
                                ),
                              ),
                              _FormRow(
                                label: 'Event Duration',
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _PillTextField(controller: durationController, keyboardType: TextInputType.number),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      flex: 3,
                                      child: Text('Days', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ),
                              _FormRow(
                                label: 'Event Start Time',
                                child: _TimePickerRow(
                                  time: startTime,
                                  onTap: () => _pickTime(isStart: true),
                                ),
                              ),
                              _FormRow(
                                label: 'Event End Time',
                                child: _TimePickerRow(
                                  time: endTime,
                                  onTap: () => _pickTime(isStart: false),
                                ),
                              ),
                              _FormRow(
                                label: 'Event Location',
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _PillTextField(controller: locationController),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
                                  ],
                                ),
                              ),
                              _FormRow(
                                label: 'Upload Paperwork',
                                alignTop: true,
                                child: GestureDetector(
                                  onTap: () => viewModel.pickPaperwork(),
                                  child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: viewModel.paperworkFile != null
                                          ? Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                viewModel.paperworkFile!.name,
                                                style: const TextStyle(color: Colors.black, fontSize: 12),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          : const Icon(Icons.upload_outlined, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              _FormRow(
                                label: 'Upload Event Poster',
                                alignTop: true,
                                child: GestureDetector(
                                  onTap: () => viewModel.pickImage(true),
                                  child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: viewModel.posterImage != null
                                          ? Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                viewModel.posterImage!.name,
                                                style: const TextStyle(color: Colors.black, fontSize: 12),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          : const Icon(Icons.image_outlined, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              _FormRow(
                                label: 'Upload Event Header',
                                alignTop: true,
                                child: GestureDetector(
                                  onTap: () => viewModel.pickImage(false),
                                  child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: viewModel.headerImage != null
                                          ? Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                viewModel.headerImage!.name,
                                                style: const TextStyle(color: Colors.black, fontSize: 12),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          : const Icon(Icons.image_outlined, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              _FormRow(
                                label: 'Number of Slots',
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _PillTextField(
                                        controller: slotsController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      flex: 3,
                                      child: Text('Slots', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ),
                              _FormRow(
                                label: 'Registration Fee',
                                child: Row(
                                  children: [
                                    Expanded(child: _PillTextField(
                                      controller: feeRinggitController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
                                    )),
                                    const SizedBox(width: 8),
                                    const Text('Ringgit', style: TextStyle(color: Colors.white, fontSize: 10)),
                                    const SizedBox(width: 8),
                                    Expanded(child: _PillTextField(
                                      controller: feeCentsController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                                    )),
                                    const SizedBox(width: 8),
                                    const Text('Cents', style: TextStyle(color: Colors.white, fontSize: 10)),
                                  ],
                                ),
                              ),
                              _FormRow(
                                label: 'Attendee Merits',
                                child: _PillTextField(
                                  controller: attendeeMeritController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
                                ),
                              ),
                              _FormRow(
                                label: 'Crew Merits',
                                child: _PillTextField(
                                  controller: crewMeritController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
                                ),
                              ),
                              _FormRow(
                                label: 'List Category',
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 28,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            dropdownColor: Colors.white,
                                            style: const TextStyle(color: Colors.black, fontSize: 12),
                                            hint: const Text('Select Display Row', style: TextStyle(color: Colors.black54, fontSize: 10)),
                                            value: selectedCategory,
                                            icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.grey, size: 16),
                                            items: ['Sports', 'Academic', 'Arts', 'Cultural', 'Other']
                                                .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.black, fontSize: 12))))
                                                .toList(),
                                            onChanged: (v) => setState(() => selectedCategory = v),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.check_box_outline_blank, color: Colors.white, size: 20),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // ── Action Buttons ────────────────────────────────
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: viewModel.isLoading ? null : () => _submit(viewModel),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E5BB8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: viewModel.isLoading
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                                      : const Text('Add Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Normally pops or clears
                                    _formKey.currentState?.reset();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFA01515),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  final String label;
  final Widget child;
  final bool alignTop;

  const _FormRow({required this.label, required this.child, this.alignTop = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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

class _PillTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _PillTextField({
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.black, fontSize: 13),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _PillContainer extends StatelessWidget {
  final Widget child;

  const _PillContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

class _TimePickerRow extends StatelessWidget {
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimePickerRow({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String hour = '';
    String minute = '';
    if (time != null) {
      hour = time!.hourOfPeriod == 0 ? '12' : time!.hourOfPeriod.toString().padLeft(2, '0');
      minute = time!.minute.toString().padLeft(2, '0');
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: _PillContainer(
              child: Center(child: Text(hour, style: const TextStyle(color: Colors.black, fontSize: 13))),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(':', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: _PillContainer(
              child: Center(child: Text(minute, style: const TextStyle(color: Colors.black, fontSize: 13))),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onTap,
          child: const Icon(Icons.access_time, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}
