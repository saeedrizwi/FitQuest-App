import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

class WorkoutEntry {
  final String exercise;
  final int count;
  final int calories;

  WorkoutEntry({
    required this.exercise,
    required this.count,
    required this.calories,
  });
}

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<WorkoutEntry> workouts = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchWorkoutData();
  }

  Future<void> fetchWorkoutData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final workoutRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('completedWorkouts')
        .doc(formattedDate);

    try {
      final doc = await workoutRef.get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          workouts = data.entries
              .map((e) => WorkoutEntry(
            exercise: e.key,
            count: (e.value as num).toInt(),
            calories: ((e.value as num) * 5).toInt(), // Example: 5 cal per rep
          ))
              .toList();
        });
      } else {
        setState(() {
          workouts = [];
        });
      }
    } catch (e) {
      print('Error fetching workout data: $e');
    }
  }

  int get totalCalories =>
      workouts.fold(0, (sum, w) => sum + w.calories);

  int get totalWorkouts =>
      workouts.fold(0, (sum, w) => sum + w.count);

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchWorkoutData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Progress"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: workouts.isEmpty
            ? const Center(child: Text("No workouts found for this day."))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressCard(
              title: 'Workouts Completed',
              progress: totalWorkouts / 10,
              value: '$totalWorkouts / 10',
              color: Colors.green,
            ),
            const SizedBox(height: 10),
            _buildProgressCard(
              title: 'Calories Burned',
              progress: totalCalories / 1000,
              value: '$totalCalories / 1000 kcal',
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              "Workouts Completed",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final workout = workouts[index];
                  return ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text(workout.exercise),
                    subtitle: Text(
                      '${workout.count} sets • ${workout.calories} kcal',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required String title,
    required double progress,
    required String value,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 10.0,
              percent: (progress > 1.0) ? 1.0 : progress,
              center: Text(
                '${(progress * 100).clamp(0, 100).toInt()}%',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20),
              ),
              progressColor: color,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
