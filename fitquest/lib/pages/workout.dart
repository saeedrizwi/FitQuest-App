import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitquest/vision_detector_views/pose_detector_view.dart';
import 'package:intl/intl.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            _buildWorkoutCard(
              context,
              'assets/im/press.jpg', // Replace with your optimized image path
              'Shoulder Press',
            ),
            const SizedBox(height: 20),
            _buildWorkoutCard(
              context,
              'assets/im/bicepscurl.jpg', // Replace with your optimized image path
              'Wide Grip Biceps Curl',
            ),

            const SizedBox(height: 20),
            _buildWorkoutCard(
              context,
              'assets/im/squat.jpg', // Replace with your optimized image path
              'Squats',
            ),
            const SizedBox(height: 20),
            _buildWorkoutCard(
              context,
              'assets/im/tri.JPG', // Replace with your optimized image path
              'Triceps Overhead Extension',
            ),
            const SizedBox(height: 20),
            _buildWorkoutCard(
              context,
              'assets/im/latraise.jpg', // Replace with your optimized image path
              'Lateral Raises',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, String imagePath, String label) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                imagePath,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                if (label == 'Shoulder Press') {
                  String exerciseLabel = 'Shoulder Press';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoseDetectorView(exerciseLabel: exerciseLabel),
                    ),
                  );
                } else if (label == 'Wide Grip Biceps Curl') {
                  String exerciseLabel = 'Biceps Curl';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoseDetectorView(exerciseLabel: exerciseLabel),
                    ),
                  );
                } else if (label == 'Lateral Raises') {
                  String exerciseLabel = 'Lateral Raises';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoseDetectorView(exerciseLabel: exerciseLabel),
                    ),
                  );
                } else if (label == 'Squats') {
                  String exerciseLabel = 'Squats';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoseDetectorView(exerciseLabel: exerciseLabel),
                    ),
                  );
                } else if (label == 'Triceps Overhead Extension') {
                  String exerciseLabel = 'Triceps Extension';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoseDetectorView(exerciseLabel: exerciseLabel),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label button pressed')),
                  );
                }
              },
              child: Text(label, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}


Future<void> logCompletedWorkout(String exerciseLabel) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final workoutRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('completedWorkouts')
      .doc(today);

  final doc = await workoutRef.get();
  final currentData = doc.data() ?? {};

  final currentCount = currentData[exerciseLabel] ?? 0;





  await workoutRef.set({
    exerciseLabel: currentCount + 1,
  }, SetOptions(merge: true));
}
Future<void> updateStreakIfEligible() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final now = DateTime.now();
  final todayStr = DateFormat('yyyy-MM-dd').format(now);
  final yesterdayStr = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: 1)));

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final workoutDoc = await userRef.collection('completedWorkouts').doc(todayStr).get();
  final userDoc = await userRef.get();

  int totalWorkouts = 0;
  if (workoutDoc.exists) {
    final data = workoutDoc.data()!;
    totalWorkouts = data.values.fold(0, (sum, value) {
      if (value is int) return sum + value;
      if (value is num) return sum + value.toInt();
      return sum;
    });
  }

  final userData = userDoc.data() ?? {};
  final currentStreak = userData['streak'] ?? 0;
  final lastStreakDate = userData['lastStreakDate'] ?? '';

  // If they did 10+ workouts today
  if (totalWorkouts >= 10) {
    if (lastStreakDate == yesterdayStr) {
      // ✅ Continue the streak
      await userRef.set({
        'streak': currentStreak + 1,
        'lastStreakDate': todayStr,
      }, SetOptions(merge: true));
    } else if (lastStreakDate != todayStr) {
      // 🔁 Start new streak
      await userRef.set({
        'streak': 1,
        'lastStreakDate': todayStr,
      }, SetOptions(merge: true));
    }
  } else {
    // 🛑 Check if user has missed a day (and didn't reset yet)
    final lastStreakDateTime = lastStreakDate.isNotEmpty
        ? DateTime.tryParse(lastStreakDate)
        : null;

    if (lastStreakDateTime != null) {
      final difference = now.difference(lastStreakDateTime).inDays;

      if (difference > 1) {
        // More than 1 day since last streak activity = missed streak
        await userRef.set({
          'streak': 0,
          'lastStreakDate': '',
        }, SetOptions(merge: true));
      }
    }
  }
}
