
//import 'package:path/path.dart';

import 'groups/injection_container.dart' as injection_container;



import 'package:fitquest/firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:fitquest/groups/core/presentation/widgets/person_icon.dart';
import 'package:fitquest/groups/screen_routes.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'groups/core/domain/services/notifications_service.dart';
import 'groups/core/presentation/widgets/center_content_widget.dart';

import 'groups/injection_container.dart';


import 'dart:async';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';

//import 'pages/rewards.dart';


late final List<CameraDescription> cameras;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await injection_container.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }

  runApp(FitQuestApp());
}
const double kMargin = 16.0;
const double kPageContentWidth = 600;
const double kIconSize = 24.0;

final navigatorKey = GlobalKey<NavigatorState>();

class FitQuestApp extends StatelessWidget {
  final double height = 100;
  final ValueNotifier<RemoteMessage?> notificationNotifier = ValueNotifier(null);
  final PanelController topNotificationController = PanelController();
  late final Function() unsubscribeOnMessageOpenedApp;

   FitQuestApp({super.key}){
    {
      unsubscribeOnMessageOpenedApp = getIt.get<NotificationsService>().onMessageOpenedApp(_onMessageOpenedApp);

      // If the app was completed closed and the notification was clicked
      FirebaseMessaging.instance.getInitialMessage().then((remoteMessage){
        if (remoteMessage != null) {
          getIt.get<NotificationsService>().onNotificationClicked(remoteMessage);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      builder: (context, widget) => Stack(
        children: [
          MaterialApp(
            title: 'Community',
            debugShowCheckedModeBanner: false,
            initialRoute: ScreenRoutes.loading, /// Check this file to see how the App starts: lib/features/loading/screens/loading_screen.dart
            theme: ThemeData(
              primarySwatch: Colors.indigo,
              fontFamily: 'RedHatDisplay',
            ),
            routes: screenRoutes,
            navigatorKey: navigatorKey,
          ),
          CenterContentWidget(
            child: Align(
              alignment: const Alignment(0, -1),
              child: IntrinsicHeight(
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.none,
                  child: SlidingUpPanel(
                    borderRadius: BorderRadius.circular(15),
                    slideDirection: SlideDirection.DOWN,
                    controller: topNotificationController,
                    renderPanelSheet: false,
                    isDraggable: true,
                    onPanelClosed: () => notificationNotifier.value = null,
                    minHeight: 0,
                    maxHeight: 105,
                    panel: Container(
                      clipBehavior: Clip.none,
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: notificationNotifier,
                        builder: (context, notification, _) {
                          if (notification == null) {
                            return Container();
                          }
                          return _RemoteMessageContent(
                              notification: notification,
                              onTap: () {
                                getIt.get<NotificationsService>().onNotificationClicked(notification);
                                topNotificationController.close();
                              }
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Timer? _closeNotificationAutomatically;
  void _onMessageOpenedApp(RemoteMessage event) {
    notificationNotifier.value = event;
    topNotificationController.open();

    _closeNotificationAutomatically?.cancel();
    _closeNotificationAutomatically = Timer(const Duration(seconds: 5), () {
      topNotificationController.close();
    });
  }
}


/*
class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PoseDetectionScreen()), // Ensure PoseDetectionScreen is defined
            );
          },
          child: const Text('Open Pose Detection'),
        ),
      ),
    );
  }
}

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Nutrition Section',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Progress Section',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
*/
class _RemoteMessageContent extends StatelessWidget {
  final RemoteMessage notification;
  final void Function() onTap;

  const _RemoteMessageContent({required this.notification, required void Function() this.onTap, super.key});

@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: InkWell(
      onTap: onTap,
      child: Ink(
        child: Row(
          children: [
            const PersonIcon(isGroup: false, iconSize: 30),
            const SizedBox(width: 13,),
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(flex: 5, child: Container()),
                    Text(notification.notification!.title!, style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 17, color: Colors.blue[900], fontWeight: FontWeight.w700)),
                    Flexible(flex: 1, child: Container()),
                    Text(notification.notification!.body!, maxLines: 2, style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 16, color: Colors.blue[800], fontWeight: FontWeight.w500)),
                    Flexible(flex: 5, child: Container()),
                  ]
              ),
            )
          ],
        ),
      ),
    ),
  );
}
}