import 'package:flutter/material.dart';
 // Import screen routes for navigation
import 'package:fitquest/groups/features/chat/presentation/controllers/signout_controller.dart'; // Import SignOutController

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);
  static const route = '/profile';// Mark it as const

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Icon for the back button
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to profile page (replace with your profile screen)
              },
            ),
            const Divider(),
            // Logout ListTile
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.blue),
              title: const Text('Logout'),
              onTap: () {
                // Instantiate SignOutController and call signOut
                final signOutController = SignOutController();
                signOutController.signOut(context); // Call the sign out method
              },
            ),
          ],
        ),
      ),
    );
  }
}
