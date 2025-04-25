import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:fitquest/groups/features/chat/domain/entities/detailed_conversation.dart';

import 'package:fitquest/groups/features/chat/presentation/controllers/users_to_talk_to_controller.dart';

import 'package:fitquest/groups/features/groups/presentation/screens/create_group_or_edit_title_screen.dart';

import 'package:fitquest/main.dart';
import 'package:fitquest/groups/screen_routes.dart';

import '../../../../../core/presentation/widgets/button_widget.dart';
import '../../../../../core/presentation/widgets/expanded_section_widget.dart';
import '../../../../../core/presentation/widgets/my_appbar_widget.dart';
import '../../../../../core/presentation/widgets/my_multiline_text_field.dart';
import '../../../../../core/presentation/widgets/my_scaffold.dart';

import '../../controllers/detailed_conversation_list_controller.dart';
import 'dart:math' as math;

import '../../controllers/signout_controller.dart';
import '../../widgets/conversation_item.dart';


class RealtimeConversationsScreen extends StatefulWidget {
  static const String route = '/conversations';

  const RealtimeConversationsScreen({Key? key}) : super(key: key);

  @override
  State<RealtimeConversationsScreen> createState() => _RealtimeConversationsScreenState();

}

class _RealtimeConversationsScreenState extends State<RealtimeConversationsScreen> {
  final detailedConversationsController = DetailedConversationListController(messagesLimitForEachConversation: 1);
  final TextEditingController searchController = TextEditingController();
  final signOutController = SignOutController();

  _RealtimeConversationsScreenState() : super();

  bool startedConversationsIsExpanded = true;
  bool allContactsIsExpanded = true;

  final usersToTalkToController = UsersToTalkToController();

  void _clearText() {
    setState(() {
      searchController.text = '';
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchController.addListener(() {
        setState(() {
          startedConversationsIsExpanded = allContactsIsExpanded = true;
        });
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    detailedConversationsController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // final double contentHeight = MediaQuery.of(context).size.height - 82;
    final double contentHeight = MediaQuery.of(context).size.height - 105;



    return MyScaffold(
      background: Container(
        color: Colors.white, // Solid blue background
      ),
      appBar: MyAppBarWidget(
        context: context,
        withBackground: true,
        // child: Text('Conversations', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kPageContentWidth),
          child: Row(
            children: [
              Expanded(
                child:  MyMultilineTextField(
                  hintText: 'Search for conversations',
                  controller: searchController,
                  fillColor: Colors.blue[800],
                  maxLines: 1,
                  suffixIcon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: searchController.text.isEmpty
                        ? Icon(Icons.search_rounded, color: Colors.blue[900]!, size: 27)
                        : InkWell(
                      onTap: _clearText,
                      child: Ink(
                        child: const Icon(Icons.clear_rounded, color: Colors.white, size: 27,),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(height: contentHeight, width: MediaQuery.of(context).size.width,),
          SingleChildScrollView(
            clipBehavior: Clip.none,
            child: Column(
              children: [
                StreamBuilder(
                  stream: detailedConversationsController.stream,
                  builder: (context, conversationsSnapshot) {
                    if(conversationsSnapshot.hasError){
                      log("An error occurred on ListenToConversationsWithMessages: ${conversationsSnapshot.error ?? "null"}");
                      return Container();
                    }
                    if(!conversationsSnapshot.hasData || conversationsSnapshot.data!.isEmpty){
                      return Container();
                    }
                    final conversations = filteredConversations(conversationsSnapshot.data!);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Subtitle(title: 'Conversations (${conversations.length.toString()})', isExpanded: startedConversationsIsExpanded, toggleExpand: (expand){setState(() {startedConversationsIsExpanded = expand;});}),
                        ExpandedSection(
                          expand: startedConversationsIsExpanded,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7, bottom: 10),
                            child: Column(
                              children: conversations.mapIndexed((index, conversation) {
                                final uid = conversation.uidForDirectConversation;
                                if (uid == null || conversation.isGroup) {
                                  // Skip fetching streak for groups or null UIDs
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: ConversationItem(
                                      conversationId: conversation.conversationId,
                                      isGroup: conversation.isGroup,
                                      uidForDirectConversation: uid,
                                      title: conversation.title,
                                      lastMessage: conversation.messages.lastOrNull,
                                      typingUsers: conversation.typingUsers,
                                      removeConversationCallback: () {
                                        detailedConversationsController.exitConversation(conversationId: conversation.conversationId);
                                      },
                                    ),
                                  );
                                }

                                // For direct conversations, fetch streak
                                return StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                                  builder: (context, snapshot) {
                                    final streak = (snapshot.data?.data() as Map<String, dynamic>?)?['streak'] ?? 0;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: ConversationItem(
                                        conversationId: conversation.conversationId,
                                        isGroup: conversation.isGroup,
                                        uidForDirectConversation: uid,
                                        title: conversation.title,
                                        lastMessage: conversation.messages.lastOrNull,
                                        typingUsers: conversation.typingUsers,
                                        removeConversationCallback: () {
                                          detailedConversationsController.exitConversation(conversationId: conversation.conversationId);
                                        },
                                        trailing: streak > -1
                                            ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.lightBlue,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('⚡', style: TextStyle(fontSize: 13, color: Colors.yellowAccent[800])),
                                              const SizedBox(width: 4),
                                              Text('$streak', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                            ],
                                          ),
                                        )
                                            : null,
                                      ),
                                    );
                                  },
                                );

                              }).toList(),

                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (!startedConversationsIsExpanded)
                  const SizedBox(height: 15,),
                StreamBuilder(
                  stream: usersToTalkToController.stream(),
                  builder: (context, snapshotContacts) {
                    if(snapshotContacts.hasError){
                      log("An error occurred on FutureBuilder ReadAllContacts: ${snapshotContacts.error ?? "null"} ${snapshotContacts.data ?? "null"}");
                      return SizedBox(
                        height: contentHeight,
                        child: const Center(child: Text("An error occurred. Please try again later", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),),
                      );
                    }
                    if(!snapshotContacts.hasData){
                      return SizedBox(
                        height: contentHeight,
                        child: Center(child: CircularProgressIndicator(color: Colors.blue[100],),),
                      );
                    }
                    final contacts = snapshotContacts.data!
                        .where((element) => ("${element.firstName} ${element.lastName}").toLowerCase().contains(searchController.text.toLowerCase()));

                    if(contacts.isEmpty && !detailedConversationsController.hasData){
                      return SizedBox(
                          height: contentHeight,
                          child: Column(
                            mainAxisAlignment: searchController.text.isEmpty
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                            children: [
                              Icon(Icons.supervised_user_circle, color: Colors.white.withOpacity(.5), size: 80),
                              SizedBox(height: 10,),
                              const Text("No conversation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18), textAlign: TextAlign.center,),
                              const SizedBox(height: 10,),
                              Text(searchController.text.isEmpty
                                  ? "Create another account and start playing :)"
                                  : "No conversation matches the filter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15), textAlign: TextAlign.center,),
                              const SizedBox(height: 22,),
                              ButtonWidget(text: 'LOGOUT', isSmall: true, width: 150, onPressed: () {
                                signOutController.signOut(context);
                              },)
                            ],
                          )
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Subtitle(title: 'Contacts (${contacts.length.toString()})', isExpanded: allContactsIsExpanded, toggleExpand: (expand){setState(() {allContactsIsExpanded = expand;});}),
                        ExpandedSection(
                          expand: allContactsIsExpanded,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 8,),
                              ...contacts.map((user) {
                                return StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                                  builder: (context, snapshot) {
                                    final streak = (snapshot.data?.data() as Map<String, dynamic>?)?['streak'] ?? 0;

                                    // final streakText = streak > -1 ? ' ⚡ $streak' : '';
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: ConversationItem(
                                        conversationId: user.conversationId,
                                        title: '${user.fullName}',

                                        uidForDirectConversation: user.uid,
                                        trailing:  streak > -1
                                      ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.lightBlue,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '⚡',
                                            style: TextStyle(fontSize: 13, color: Colors.yellowAccent[800]),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$streak',
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    )
                                        : null,
                                      ),
                                    );
                                  },
                                );
                              }).toList(),

                              const SizedBox(height: 18,),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder(
          stream: usersToTalkToController.stream(),
          builder: (context, snapshot) {
            return Padding(
              padding: EdgeInsets.only(right: math.max(0, (MediaQuery.of(context).size.width - kPageContentWidth) / 2)),
              child: Visibility(
                visible: snapshot.data?.isNotEmpty == true,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).pushNamed(ScreenRoutes.createGroupOrEditTitle, arguments: CreateGroupOrEditTitleArgs());
                  },
                  backgroundColor: Colors.indigo[900],
                  label: const Text("Create Group", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  icon: const Icon(Icons.group, color: Colors.white),
                ),
              ),
            );
          }
      ),
    );
  }

  List<DetailedConversation> filteredConversations(List<DetailedConversation> conversations) {
    String _unformat(String? text) => (text ?? '').toLowerCase().replaceAll(' ', '');

    return conversations
        .where((element) => _unformat(element.messages.lastOrNull?.text).contains(_unformat(searchController.text)) == true
            || _unformat(element.title).contains(_unformat(searchController.text))
            || element.users.length <= 1
            || element.users.any((user) => _unformat(user.fullName).contains(_unformat(searchController.text)))
        ).toList();
  }
}

class _Subtitle extends StatelessWidget {
  final String title;
  final ValueChanged<bool> toggleExpand;
  final bool isExpanded;

  const _Subtitle({Key? key, required this.title, required this.toggleExpand, required this.isExpanded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: InkWell(
        onTap: () => toggleExpand(!isExpanded),
        child: Ink(
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(isExpanded ? 'HIDE' : 'SHOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                    Icon(isExpanded ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined , color: Colors.white, size: 22,),
                    const SizedBox(width: 7,),
                    Expanded(child: Container(height: 1, color: Colors.blue[100],)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 2),
                child: Text(title, style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              Expanded(child: Container(height: 1, color: Colors.blue[100],)),
            ],
          ),
        ),
      ),
    );
  }
}
