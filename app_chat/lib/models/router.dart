import 'package:app_chat/models/auth_gate.dart';
import 'package:app_chat/pages/chats.dart';
import 'package:app_chat/pages/profile_page.dart';
import 'package:app_chat/pages/register.dart';
import 'package:app_chat/pages/settings_page.dart';
import 'package:app_chat/pages/signIn_page.dart';
import 'package:app_chat/pages/users_list_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  /*redirect: (context, state) {
    var user = AuthService().getUserFromSupabase();
    if (user != null) {
      developer.log('USER IS FOUND');
      return null;
    } else {
      developer.log('USER IS NOT FOUND');
      return SigninPage.path;
    }
  },*/
  routes: [
    GoRoute(
      path: '/',
      name: "home",
      builder: (context, state) => AuthGate(),
    ),
    GoRoute(
      path: SigninPage.path,
      builder: (context, state) => SigninPage(),
    ),
    GoRoute(
      path: Register.path,
      builder: (context, state) => Register(),
    ),
    /* GoRoute(
      path: ChatPage.path,
      builder: (context, state) => ChatPage(),
    ),*/
    GoRoute(
        path: UsersListPage.path, builder: (context, state) => UsersListPage()),
    GoRoute(
      path: ProfilePage.path,
      builder: (context, state) => ProfilePage(),
    ),
    GoRoute(
      path: SettingsPage.path,
      builder: (context, state) => SettingsPage(),
    ),
    GoRoute(
      path: Chats.path,
      builder: (context, state) => Chats(),
    )
  ],
);
