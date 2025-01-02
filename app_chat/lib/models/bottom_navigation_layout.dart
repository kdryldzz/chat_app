import 'package:app_chat/pages/chats.dart';
import 'package:app_chat/pages/profile_page.dart';
import 'package:app_chat/pages/users_list_page.dart';
import 'package:app_chat/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BottomNavigationLayout extends StatefulWidget {
  final int currentIndex;
  final Widget body;

  const BottomNavigationLayout({
    super.key,
    required this.currentIndex,
    required this.body,
  });

  @override
  State<BottomNavigationLayout> createState() => _BottomNavigationLayoutState();
}

class _BottomNavigationLayoutState extends State<BottomNavigationLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });

      switch (index) {
        case 0:
          context.go(ProfilePage.path);
          break;
        case 1:
          context.go(UsersListPage.path);
          break;
        case 2:
          context.go(Chats.path);
          break;
        case 3:
          context.go(SettingsPage.path);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.body,
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Profile"),
            selectedColor: Colors.blue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.supervisor_account),
            title: const Text("Users"),
            selectedColor: Colors.green,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.chat_bubble_outline_outlined),
            title: const Text("Chats"),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.settings),
            title: const Text("Settings"),
            selectedColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
