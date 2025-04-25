import 'package:fitquest/groups/core/domain/entities/user_public.dart';
import 'package:fitquest/groups/core/domain/services/users_service.dart';
import 'package:fitquest/groups/injection_container.dart';




class UsersToTalkToController {

  Stream<List<UserPublic>> stream() {
    return getIt.get<UsersService>().streamAllUsersExceptLogged();
  }

}