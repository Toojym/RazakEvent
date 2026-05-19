import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_event_view.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventView()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
