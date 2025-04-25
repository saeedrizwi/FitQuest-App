import 'package:flutter/material.dart';
//import 'package:fitquest/groups/features/call/presentation/screens/call_screen.dart';
import 'package:fitquest/groups/features/groups/presentation/screens/add_participants_screen.dart';
import 'package:fitquest/groups/features/groups/presentation/screens/manage_group_participants_screen.dart';
//import 'package:path/path.dart';
import '../auth/auth_gate.dart';
import '../pages/home.dart';
import '../pages/leaderboard.dart';
import '../pages/profile_page.dart';
import 'features/chat/presentation/screens/realtime_chat_screen/realtime_chat_screen.dart';
import 'features/chat/presentation/screens/realtime_conversations_screen/realtime_conversations_screen.dart';
import 'features/groups/presentation/screens/create_group_or_edit_title_screen.dart';
import 'features/loading/screens/loading_screen.dart';
import 'features/login_and_registration/presentation/screens/login_and_registration_screen.dart';


class ScreenRoutes {
  /// home route
  static const loading = LoadingScreen.route;
  static const login = LoginAndRegistrationScreen.route;
  static const conversations = RealtimeConversationsScreen.route;
  static const chat = RealtimeChatScreen.route;
  static const createGroupOrEditTitle = CreateGroupOrEditTitleScreen.route;
  static const addGroupParticipants = AddGroupParticipantsScreen.route;
  static const manageGroupParticipants = ManageGroupParticipantsScreen.route;
  static const profilePage = ProfilePage.route;
  static const authGate = AuthGate.route;
  static const home = FitQuestHomePage.route;
  static const leader = LeaderboardPage.route;

  //static const call = CallScreen.route;
}

Map<String, Widget Function(BuildContext)> screenRoutes = {
  ScreenRoutes.loading: (context) =>  const LoadingScreen(),
  ScreenRoutes.login: (context) =>  const LoginAndRegistrationScreen(),
  ScreenRoutes.chat: (context) =>  const RealtimeChatScreen(),
  ScreenRoutes.conversations: (context) => const RealtimeConversationsScreen(),
  ScreenRoutes.createGroupOrEditTitle: (context) => const CreateGroupOrEditTitleScreen(),
  ScreenRoutes.addGroupParticipants: (context) => const AddGroupParticipantsScreen(),
  ScreenRoutes.manageGroupParticipants: (context) => const ManageGroupParticipantsScreen(),
  ScreenRoutes.profilePage: (context) => const ProfilePage(),
  ScreenRoutes.authGate: (context) => const AuthGate(),
  ScreenRoutes.home: (context) => const FitQuestHomePage(),
  ScreenRoutes.leader: (context) => const LeaderboardPage(),
  //ScreenRoutes.call: (context) => const CallScreen(),
};