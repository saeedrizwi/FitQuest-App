import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// ✅ Fetch user's current coin balance
Future<int> getUserCoins() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 0; // Return 0 if user is not logged in

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final doc = await userRef.get();

  if (doc.exists) {
    return doc.data()?['coins'] ?? 0; // Return coin balance or 0 if missing
  }
  return 0;
}

// ✅ Function to reward daily login
Future<void> rewardDailyLogin(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return; // Ensure user is logged in

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final doc = await userRef.get();
  final data = doc.data() ?? {}; // Ensure a default map if document doesn't exist
  final lastLogin = data['lastLogin'] ?? '';

  if (lastLogin == today) {
    return; // Already claimed today's reward
  }

  // Reward daily coins
  final newCoins = (data['coins'] ?? 0) + 10;

  // ✅ Use `.set()` with merge to ensure data consistency
  await userRef.set({
    'coins': newCoins,
    'lastLogin': today,
  }, SetOptions(merge: true)); // Merge prevents overwriting other user fields

  // 🎉 Show updated coin balance in popup
  final updatedCoins = await getUserCoins();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Daily Reward! 🎉"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on, color: Colors.amber, size: 50),
            const SizedBox(height: 10),
            const Text("You earned 10 coins for logging in today!"),
            const SizedBox(height: 5),
            Text("Total Coins: $updatedCoins", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Collect"),
          ),
        ],
      );
    },
  );
}
Future<int> rewardWorkoutCompletion() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 0;

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final doc = await userRef.get();
  final data = doc.data() ?? {};

  final currentCoins = data['coins'] ?? 0;
  final newCoins = currentCoins + 50;

  await userRef.set({
    'coins': newCoins,
  }, SetOptions(merge: true));

  return newCoins;
}
