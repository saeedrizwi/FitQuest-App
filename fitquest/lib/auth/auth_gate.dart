import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../groups/features/login_and_registration/presentation/screens/login_and_registration_screen.dart';
import '../pages/home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  static const route ='/auth';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return const FitQuestHomePage(); // User is logged in
          } else {
            return LoginAndRegistrationScreen();
          }
        },
      )

    );
  }
}