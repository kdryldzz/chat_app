import 'package:app_chat/models/auth_service.dart';
import 'package:app_chat/models/bottom_navigation_layout.dart';
import 'package:app_chat/pages/signIn_page.dart';
import 'package:app_chat/pages/users_list_page.dart';
import 'package:app_chat/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  static const path = '/settings_page';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _currentIndex = 3;
  final authService = AuthService();

  void logOut() async {
    await authService.signOut();
    context.go(SigninPage.path);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationLayout(
        currentIndex: _currentIndex,
        body: Scaffold(
          appBar: AppBar(
            title: Text(
              "settings",
              style: context.AppBarStyle,
            ),
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  context.go(UsersListPage.path);
                },
                icon: Icon(Icons.arrow_back)),
          ),
          body: Center(
            child: Column(
              children: [
                GestureDetector(
                  child: SettingsCardWidget(
                    title: 'log Out',
                  ),
                  onTap: logOut,
                )
              ],
            ),
          ),
        ));
  }
}

class SettingsCardWidget extends StatelessWidget {
  const SettingsCardWidget({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      child: Row(
        children: [
          SizedBox(
            width: 20,
          ),
          Text(
            title,
            style: context.textStyle1,
          ),
          Spacer(),
          Container(
              width: 40, height: 40, child: Icon(Icons.exit_to_app_outlined))
        ],
      ),
    );
  }
}
