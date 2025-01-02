import 'package:app_chat/models/bottom_navigation_layout.dart';
import 'package:app_chat/pages/chat_page.dart';
import 'package:app_chat/pages/users_list_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class Chats extends StatefulWidget {
  static const path = "/chats";

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  final _currentIndex = 2;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    Supabase.initialize;
    fetchCurrentUser();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      // Aktif kullanıcıyı içeren tüm odaları getir.
      final response = await supabase
          .from('rooms')
          .select('user1_id, user2_id')
          .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId');

      // Eğer response boşsa, kullanıcı yok.
      if (response.isEmpty) {
        setState(() {
          users = [];
          isLoading = false;
        });
        return;
      }

      // Partner kullanıcıların ID'lerini çıkar.
      final userIds =
          <String>{}; // Set kullanımı, tekrarlı ID'leri önlemek için
      for (var room in response) {
        if (room['user1_id'] == currentUserId) {
          userIds.add(room['user2_id'] as String);
        } else if (room['user2_id'] == currentUserId) {
          userIds.add(room['user1_id'] as String);
        }
      }

      if (userIds.isNotEmpty) {
        // Partner kullanıcıların detaylarını getir.
        final usersResponse = await supabase
            .from('users')
            .select('*')
            .inFilter('id', userIds.toList()); // `inFilter` kullanımı

        if (usersResponse.isNotEmpty) {
          setState(() {
            users = List<Map<String, dynamic>>.from(usersResponse);
            isLoading = false;
          });
        } else {
          setState(() {
            users = [];
            isLoading = false;
          });
        }
        users.sort((a, b) => a['username']
            .toString()
            .toLowerCase()
            .compareTo(b['username'].toString().toLowerCase()));
      } else {
        setState(() {
          users = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching users: $e');
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

  // Odayı silme işlemi
  /*Future<void> deleteRoom(String receiverUser) async {
    try {
      // Silinecek odanın sorgusu (currentUser ve receiverUser arasında olan)
      final response = await supabase
          .from('rooms')
          .delete()
          .or('user1_id.eq.$currentUserId,user2_id.eq.$receiverUser')
          .or('user1_id.eq.$receiverUser,user2_id.eq.$currentUserId');

      // response null kontrolü yapalım
      if (response == null || response.isEmpty) {
        print('No matching room found.');

        return; // Eğer odalar yoksa işlem yapma
      }

      // Odayı başarıyla silerse, tekrar kullanıcıları ve odaları yükleyebilirsiniz
      print('Room deleted successfully');
      fetchUsers(); // Odayı sildikten sonra güncellenmiş kullanıcıları al
    } catch (e) {
      print('Error deleting room: $e');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return BottomNavigationLayout(
      currentIndex: _currentIndex,
      body: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sohbetler',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : users.isEmpty
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('no user found.'),
                      ElevatedButton(
                          onPressed: () {
                            context.go(UsersListPage.path);
                          },
                          child: Text(
                            'start a new chat',
                            style: TextStyle(color: Colors.white),
                          ))
                    ],
                  ))
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
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
                            //kullanıcıya tıklanılarak işlem yapılabilir
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                          senderUserId: currentUserId!,
                                          receiverUserId: user['id'],
                                          username: user['username'],
                                        )));

                            print(
                                'Selected user: ${user['username']}, receiverUserid: ${user['id']}');
                            developer.log(
                                'Selected user: ${user['username']},senderUSerId:${currentUserId} ,receiverUserid: ${user['id']}');
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
