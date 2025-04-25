import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../groups/features/chat/presentation/screens/realtime_conversations_screen/realtime_conversations_screen.dart';
//import 'profile_page.dart';
import 'rewards.dart';
import 'workout.dart';
import 'progress.dart';
import 'package:fitquest/groups/screen_routes.dart';

class FitQuestHomePage extends StatefulWidget {
  const FitQuestHomePage({super.key});
  static const route ='/home';
  /* void logout(BuildContext context) async {
    final auth = AuthService();
    try {
      await auth.signOut();
      // Navigate to the login page and clear the navigation stack
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      // Show error dialog if logout fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
        ),
      );
    }
  }



  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),

      ),
    );
  }

  */

  @override
  _FitQuestHomePageState createState() => _FitQuestHomePageState();
}

class _FitQuestHomePageState extends State<FitQuestHomePage> {
  int _selectedIndex = 0;
  //int _coins = 0;
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeReward();
    });
  }

  Future<void> _initializeReward() async {
    await updateStreakIfEligible(); // ✅ Wait for streak update
    rewardDailyLogin(context);      // ✅ Then reward login
    setState(() {});                // ✅ Refresh UI so StreamBuilder updates
  }

 /* Future<void> _fetchCoins() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      setState(() {
        _coins = doc.data()?['coins'] ?? 0;
      });
    }
  }

  */

  // Bottom Navigation Pages
  static final List<Widget> _pages = <Widget>[
    const WorkoutPage(), // 0
    // 1
    const ProgressPage(),
    const RealtimeConversationsScreen()// 2

    // 3 (Make sure this is included)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });


  }


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please log in"));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FitQuest',
          style: TextStyle(color: Colors.white), // 👈 This sets the text color
        ),
        backgroundColor: Colors.blue,

        toolbarHeight: 80,
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(),
                );
              }

              // ✅ Cast Firestore data to Map<String, dynamic>
              final data = snapshot.data!.data() as Map<String, dynamic>?;

              // ✅ Retrieve coins safely
              final coins = data?['coins'] ?? 0;

              return Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Row(
                  children: [
                    // Streak display first
                    const Text('⚡', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 4),
                    Text(
                      '${data?['streak'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.amber),

                    ),
                    const SizedBox(width: 20),

                    // Coins in a rounded box
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(ScreenRoutes.leader);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.amber),
                            const SizedBox(width: 5),
                            Text(
                              '$coins',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );

            },
          ),

          /*
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person), // Settings icon
          ),

           */
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final userData = snapshot.data!.data() as Map<String, dynamic>?;

                  final firstName = userData?['firstName'] ?? '';
                  final lastName = userData?['lastName'] ?? '';
                  final email = FirebaseAuth.instance.currentUser?.email ?? 'Guest';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/im/avatar.jpg'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$firstName $lastName',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  );
                },
              ),
            ),


            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context); // close drawer first
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // Navigate to login
              },
            ),
          ],
        ),
      ),

      body: Center(
        child:
        _pages.elementAt(_selectedIndex), // This accesses the correct index
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          /* BottomNavigationBarItem(
            icon: Icon(Icons.local_dining),
            label: 'Nutrition',
          ),*/
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Community', // Ensure this is defined
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped, // Calls the method to handle index change
      ),
    );
  }
}
