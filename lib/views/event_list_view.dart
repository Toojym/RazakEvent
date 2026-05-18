import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/event_viewmodel.dart';

class EventListView extends StatelessWidget {
  const EventListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventViewModel>();

    if (vm.isLoading) return const Center(child: CircularProgressIndicator());
    if (vm.errorMessage != null) return Center(child: Text(vm.errorMessage!));
    if (vm.events.isEmpty) return const Center(child: Text('No events yet.'));

    return ListView.builder(
      itemCount: vm.events.length,
      itemBuilder: (context, index) {
        final event = vm.events[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text(event.date.toLocal().toString()),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => vm.deleteEvent(event.id),
          ),
        );
      },
    );
  }
}