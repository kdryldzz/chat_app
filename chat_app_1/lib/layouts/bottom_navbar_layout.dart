import 'package:chat_app_1/screens/chats_list_screen.dart';
import 'package:chat_app_1/screens/profile_screen.dart';
import 'package:chat_app_1/screens/search_screen.dart';
import 'package:chat_app_1/screens/settings_screen.dart';
import 'package:flutter/material.dart';
class BottomNavbarLayout extends StatefulWidget {
  final int selectedIndex;
  const BottomNavbarLayout({super.key, this.selectedIndex = 1});

  @override
  State<BottomNavbarLayout> createState() => _BottomNavbarLayoutState();
}

class _BottomNavbarLayoutState extends State<BottomNavbarLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  static const List<Widget> _pages = <Widget>[
    ProfileScreen(),
    SearchScreen(),
    ChatsListScreen(),
    SettingsScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
               BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble),
                label: 'Chats',
              ),
               BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.deepPurple,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}