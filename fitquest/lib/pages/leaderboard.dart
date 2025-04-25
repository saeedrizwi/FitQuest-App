import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fitquest/groups/features/chat/presentation/widgets/conversation_item.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});
  static const String route = '/leaderboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Leaderboard'),
        backgroundColor: Colors.blue[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('coins', descending: true)
            .limit(20)
            .snapshots(), // 👈 Live updates!
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('No leaderboard data available.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final name = user['firstName'] ?? 'Unknown';
              final coins = user['coins'] ?? 0;
              final streak = user['streak'] ?? 0;
              final uid = users[index].id;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                child: ConversationItem(
                  conversationId: uid,
                  title: "#${index + 1}  $name",
                  uidForDirectConversation: uid,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                      Text(' $coins', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      const Text('⚡', style: TextStyle(fontSize: 18)),
                      Text('$streak', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

    );
  }
}
