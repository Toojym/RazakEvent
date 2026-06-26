import 'package:razak_event/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../viewmodels/edit_event_viewmodel.dart';
import 'logo_view.dart';

class EditEventView extends StatelessWidget {
  final EventModel event;
  const EditEventView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditEventViewModel(),
      child: _EditEventViewBody(event: event),
    );
  }
}

class _EditEventViewBody extends StatefulWidget {
  final EventModel event;
  const _EditEventViewBody({required this.event});

  @override
  State<_EditEventViewBody> createState() => _EditEventViewBodyState();
}

class _EditEventViewBodyState extends State<_EditEventViewBody> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController durationController;
  late TextEditingController feeRinggitController;
  late TextEditingController feeCentsController;
  
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime; // Just placeholder for now

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event.title);
    descriptionController = TextEditingController(text: widget.event.description);
    locationController = TextEditingController(text: widget.event.location);
    durationController = TextEditingController(text: '1');
    final int ringgit = widget.event.fee.floor();
    final int cents = ((widget.event.fee - ringgit) * 100).round();
    feeRinggitController = TextEditingController(text: ringgit > 0 ? '$ringgit' : '');
    feeCentsController = TextEditingController(text: cents > 0 ? cents.toString().padLeft(2, '0') : '');
    selectedDate = widget.event.date;
    startTime = TimeOfDay(hour: widget.event.date.hour, minute: widget.event.date.minute);
    endTime = TimeOfDay(hour: widget.event.date.hour + 2, minute: widget.event.date.minute);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    durationController.dispose();
    feeRinggitController.dispose();
    feeCentsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? (startTime ?? TimeOfDay.now()) : (endTime ?? TimeOfDay.now()),
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditEventViewModel>();

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
                'Edit Event',
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
                            onTap: () => vm.pickPaperwork(),
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: vm.paperworkFile != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          vm.paperworkFile!.name,
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
                            onTap: () => vm.pickPoster(),
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: vm.posterFile != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          vm.posterFile!.name,
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
                          label: 'Registration Fee',
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Text('RM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: _PillTextField(
                                  controller: feeRinggitController,
                                  hintText: '0',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text('.', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                flex: 2,
                                child: _PillTextField(
                                  controller: feeCentsController,
                                  hintText: '00',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // ── Action Buttons ────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: vm.isLoading ? null : () async {
                              if (_formKey.currentState!.validate()) {
                                if (selectedDate == null || startTime == null) return;
                                
                                final updatedDate = DateTime(
                                  selectedDate!.year,
                                  selectedDate!.month,
                                  selectedDate!.day,
                                  startTime!.hour,
                                  startTime!.minute,
                                );

                                double fee = (int.tryParse(feeRinggitController.text) ?? 0).toDouble() +
                                    ((int.tryParse(feeCentsController.text) ?? 0) / 100.0);

                                final success = await vm.updateEvent(
                                  originalEvent: widget.event,
                                  title: titleController.text,
                                  description: descriptionController.text,
                                  location: locationController.text,
                                  date: updatedDate,
                                  fee: fee,
                                );

                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Event updated successfully!')),
                                  );
                                  Navigator.pop(context);
                                } else if (!success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(vm.errorMessage ?? 'Update failed')),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E5BB8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: vm.isLoading
                                ? const SizedBox(height: 20, width: 20, child: CustomLoadingIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Update Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
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
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;

  const _PillTextField({
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.hintText,
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
        style: const TextStyle(color: Colors.black, fontSize: 10),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 10),
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
