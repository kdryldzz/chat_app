import 'package:chat_app_1/controllers/global_controller.dart';
import 'package:chat_app_1/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_1/models/users.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final GlobalController _controller = GlobalController();
  late Future<List<Users>> _usersFuture;
  String query = '';

  @override
  void initState() {
    super.initState();
    _usersFuture = _controller.listUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             SizedBox(height: 30.h), // Reduced height
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w), // Adjusted padding
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0.r),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Users>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error.toString()}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No users found'));
                  } else {
                    final users = snapshot.data!;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        if (user.username.toLowerCase().contains(query.toLowerCase())) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                user.avatar_url.isNotEmpty
                                    ? "https://wjxfpnsrjsofhfstivls.supabase.co/storage/v1/object/public/images/uploads/${user.id}/${user.avatar_url}"
                                    : 'assets/images/profile.png', // Varsayılan fotoğraf
                              ),
                            ),
                            title: Text(user.username,),
                            subtitle: Text(user.email),
                            onTap: () async {
                              final roomId = await _controller.getOrCreateRoom(user.id);
                              if (roomId.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(roomId: roomId),
                                  ),
                                );
                              } else {
                                print('Failed to create or get room');
                              }
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
