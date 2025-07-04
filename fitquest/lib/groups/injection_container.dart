import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitquest/groups/core/data/data_sources/auth_ds.dart';
import 'package:fitquest/groups/core/domain/services/users_service.dart';

import 'package:fitquest/groups/features/chat/domain/services/messages_service.dart';
import 'package:get_it/get_it.dart';
import 'core/domain/services/notifications_service.dart';

import 'features/chat/data/data_sources/messages_ds.dart';
import 'core/data/data_sources/users_ds.dart';
import 'core/domain/services/auth_service.dart';
import 'features/chat/data/data_sources/typing_ds.dart';
import 'features/groups/data/datasources/groups_ds.dart';
import 'features/groups/domain/services/groups_service.dart';
import 'package:fitquest/firebase_options.dart';

/// Service locator
final getIt = GetIt.instance;

Future<void> init () async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.enablePersistence().catchError((err) { // for web
    print("Could not enable offline mode, please, check if the App is opened in another Tab or try another browser");
    print(err.toString());
  });

 // getIt.registerLazySingleton(() => CallDS(firebaseFunctions: FirebaseFunctions.instance));
  getIt.registerLazySingleton(() => TypingDS(firestore: FirebaseFirestore.instance, authService: getIt.get<AuthService>()));
  getIt.registerLazySingleton(() => GroupsDS(firestore: FirebaseFirestore.instance, authService: getIt.get<AuthService>()));
  getIt.registerLazySingleton(() => NotificationsService(usersDs: getIt.get<UsersDS>(), messaging: FirebaseMessaging.instance, onMessage: FirebaseMessaging.onMessage, onMessageOpenedApp: FirebaseMessaging.onMessageOpenedApp,));
  getIt.registerLazySingleton(() => UsersDS(authDS: getIt.get<AuthDS>()));
  getIt.registerLazySingleton(() => AuthDS(firebaseAuth: FirebaseAuth.instance));
  getIt.registerLazySingleton(() => MessagesDS(authService: getIt.get<AuthService>(), firestore: FirebaseFirestore.instance, typingDs: getIt.get<TypingDS>()));

  //getIt.registerLazySingleton(() => CallService(callDS: getIt.get<CallDS>()));
  getIt.registerLazySingleton(() => GroupsService(groupsDS: getIt.get<GroupsDS>(), authService: getIt.get<AuthService>()));
  getIt.registerLazySingleton(() => MessagesService(usersService: getIt.get<UsersService>(), authService: getIt.get<AuthService>(), messagesDatasource: getIt.get<MessagesDS>()));
  getIt.registerLazySingleton(() => UsersService(usersRemoteDataSource: getIt.get<UsersDS>(),));
  getIt.registerLazySingleton(() => AuthService(authDS: getIt.get<AuthDS>(), notificationsController: getIt.get<NotificationsService>(), usersDS: getIt.get<UsersDS>(),));
}

