import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Objective',
              ),
            ),
            const SizedBox(height: 16),
            // Your emergency contacts list would go here
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: const Text('Emergency Contact 1'),
                subtitle: const Text('+234 800 123 4567'),
                trailing: IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    // Handle call action
                  },
                ),
              ),
            ),
            // More contacts would be listed here
          ],
        ),
      ),
    );
  }
}