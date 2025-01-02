import 'package:app_chat/models/auth_service.dart';
import 'package:app_chat/models/bottom_navigation_layout.dart';
import 'package:app_chat/pages/signIn_page.dart';
import 'package:app_chat/pages/users_list_page.dart';
import 'package:app_chat/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const path = '/profile_page';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _currentIndex = 0;

  final authService = AuthService();

  void logOut() async {
    await authService.signOut();
    context.go(SigninPage.path);
  }

  final currentEmail = AuthService().getCurrentUserEmail();
  @override
  Widget build(BuildContext context) {
    return BottomNavigationLayout(
        currentIndex: _currentIndex,
        body: Scaffold(
          appBar: AppBar(
            title: Text(
              "Profile",
              style: context.AppBarStyle,
            ),
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  context.go(UsersListPage.path);
                },
                icon: Icon(Icons.arrow_back)),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    onPressed: logOut, icon: Icon(Icons.exit_to_app_outlined)),
              )
            ],
          ),
          body: Center(
            child: Column(
              children: [
                Container(
                  child: Image.asset("images/user_logo.png"),
                  width: 220,
                  height: 220,
                ),
                Card(
                  child: Container(
                    width: 200,
                    height: 50,
                    child: Row(
                      children: [
                        Container(
                            height: 30,
                            width: 30,
                            child: Image.asset("images/user_logo.png")),
                        Text(
                          '$currentEmail',
                          style: context.textStyle1,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
              ],
            ),
          ),
        ));
  }
}
