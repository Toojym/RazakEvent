import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/create_event_viewmodel.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController attendeePointsController = TextEditingController(text: "1");
  final TextEditingController crewPointsController = TextEditingController(text: "3");
  final TextEditingController maxCapacityController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    attendeePointsController.dispose();
    crewPointsController.dispose();
    maxCapacityController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    if (!mounted) return;
    
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      selectedDate = date;
      selectedTime = time;
    });
  }

  void _submit(CreateEventViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;
    
    if (selectedDate == null || selectedTime == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date and time.")),
      );
      return;
    }

    final finalDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final errorMessage = await viewModel.submitEvent(
      title: titleController.text,
      description: descriptionController.text,
      date: finalDateTime,
      location: locationController.text,
      attendeeMeritPoints: int.parse(attendeePointsController.text),
      crewMeritPoints: int.parse(crewPointsController.text),
      maxCapacity: maxCapacityController.text.isEmpty ? null : int.parse(maxCapacityController.text),
      imageUrl: imageUrlController.text,
    );

    if (!mounted) return;

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event Created Successfully!")),
      );
      Navigator.pop(context); // Go back to Home
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
            appBar: AppBar(
              title: const Text("Create Event"),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Event Title"),
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: "Description"),
                      maxLines: 3,
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: "Location"),
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),

                    ListTile(
                      title: Text(
                        selectedDate == null || selectedTime == null
                            ? "Select Date & Time"
                            : "${selectedDate!.toLocal().toString().split(' ')[0]} at ${selectedTime!.format(context)}",
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDateTime,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: attendeePointsController,
                            decoration: const InputDecoration(labelText: "Attendee Merit Points"),
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.isEmpty) return "Required";
                              if (int.tryParse(val) == null) return "Invalid";
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: crewPointsController,
                            decoration: const InputDecoration(labelText: "Crew Merit Points"),
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.isEmpty) return "Required";
                              if (int.tryParse(val) == null) return "Invalid";
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: maxCapacityController,
                      decoration: const InputDecoration(labelText: "Max Capacity (Optional)"),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val != null && val.isNotEmpty && int.tryParse(val) == null) {
                          return "Must be a number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: "Image URL (Optional)",
                        hintText: "https://example.com/image.png",
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    viewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () => _submit(viewModel),
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text("Create Event", style: TextStyle(fontSize: 18)),
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
