import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../repositories/event_repository.dart';
import '../viewmodels/event_viewmodel.dart';
import 'create_event_view.dart';
import 'event_list_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RazakEvent Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: const Center(
        child: Text("Welcome to RazakEvent!"),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'browse_events',
            icon: const Icon(Icons.event),
            label: const Text('Browse Events'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => EventViewModel(EventRepository()),
                    child: const EventListView(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'create_event',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateEventView()),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}