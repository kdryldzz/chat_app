import 'package:chat_app_1/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_1/controllers/search_screen_controller.dart';
import 'package:chat_app_1/models/rooms.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final SearchScreenController _controller = SearchScreenController();
  late Future<List<Rooms>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _roomsFuture = _controller.ListRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MY CHATS LIST'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Rooms>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No rooms found'));
          } else {
            final rooms = snapshot.data!;
            return ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return FutureBuilder<String>(
                  future: _controller.getOtherUsername(room.room_id),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Loading...'),
                        subtitle: Text('Room ID: ${room.room_id}'),
                      );
                    } else if (userSnapshot.hasError) {
                      return ListTile(
                        title: Text('Error'),
                        subtitle: Text('Room ID: ${room.room_id}'),
                      );
                    } else {
                      final username = userSnapshot.data!;
                      return ListTile(
                        title: Text(username),
                        subtitle: Text('Room ID: ${room.room_id}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(roomId: room.room_id),
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}