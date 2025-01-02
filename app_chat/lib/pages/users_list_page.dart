import 'package:app_chat/models/bottom_navigation_layout.dart';
import 'package:app_chat/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class UsersListPage extends StatefulWidget {
  static const path = "/users_list_page";

  @override
  _UsersListPageState createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;
  final _currentIndex = 1;
  String? currentUserId;
  String searchQuery = "";
  bool isSearching =
      false; // Arama kutusunun açık mı kapalı mı olduğunu takip eder

  @override
  void initState() {
    super.initState();
    Supabase.initialize;
    fetchUsers();
    fetchCurrentUser();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await supabase.from('users').select().neq('id',
          supabase.auth.currentUser!.id); //neq ile Aktif kullanıcıyı hariç tut;
      if (mounted) {
        setState(() {
          users = List<Map<String, dynamic>>.from(response);
          filteredUsers = List.from(users); // Başlangıçta tüm kullanıcılar
          isLoading = false;
          users.sort((a, b) => a['username']
              .toString()
              .toLowerCase()
              .compareTo(b['username'].toString().toLowerCase()));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        print('Error fetching users: $e');
      }
    }
  }

  void fetchCurrentUser() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.id;
      });
    } else {
      print("No user is currently logged in.");
    }
  }

  void filterUsers(String query) {
    setState(() {
      searchQuery = query;
      filteredUsers = users
          .where((user) => user['username']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching; // Arama durumu değiştirilir
      if (!isSearching) {
        searchQuery = ""; // Arama kapatıldığında sorguyu sıfırla
        filteredUsers = List.from(users); // Tüm kullanıcıları geri getir
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationLayout(
      currentIndex: _currentIndex,
      body: Scaffold(
        appBar: AppBar(
          title: isSearching
              ? TextField(
                  onChanged: (query) => filterUsers(query),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by username...',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                  ),
                )
              : Text(
                  'All Users',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32),
                ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: isSearching ? Icon(Icons.clear) : Icon(Icons.search),
              onPressed: toggleSearch, // Arama açma/kapama işlemi
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : filteredUsers.isEmpty
                ? Center(child: Text('No users found.'))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(user['username'][0].toUpperCase()),
                          ),
                          title: Text(user['username']),
                          subtitle: Text(user['email']),
                          onTap: () {
                            // Kullanıcıya tıklanarak işlem yapılabilir
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  senderUserId: currentUserId!,
                                  receiverUserId: user['id'],
                                  username: user['username'],
                                ),
                              ),
                            );
                            developer.log(
                                'Selected user: ${user['username']}, senderUserId:${currentUserId}, receiverUserId: ${user['id']}');
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
