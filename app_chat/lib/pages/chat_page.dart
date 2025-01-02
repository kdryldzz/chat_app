import 'package:app_chat/models/auth_service.dart';
import 'package:app_chat/models/messages.dart';
import 'package:app_chat/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  static const path = "/chat_page";
  final String senderUserId;
  final String receiverUserId;
  final String username;

  const ChatPage({
    Key? key,
    required this.senderUserId,
    required this.receiverUserId,
    required this.username,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late Future<String> _roomIdFuture; // Oda ID'sini almak için
  late Stream<List<Messages>>
      _messageStream; // Mesajları realtime dinlemek için

  @override
  void initState() {
    super.initState();
    _roomIdFuture = AuthService()
        .findOrCreateRoom(widget.senderUserId, widget.receiverUserId);
  }

  void _sendMessage(String roomId) async {
    if (_messageController.text.trim().isNotEmpty) {
      await AuthService().sendMessage(
          roomId, widget.senderUserId, _messageController.text.trim());
      _messageController.clear();
    }
  }

  Future<void> deleteMessages(String roomId) async {
    final supabase = Supabase.instance.client;

    try {
      final response =
          await supabase.from('messages').delete().eq('room_id', roomId);

      if (response.error != null) {
        print('Mesajları silerken hata: ${response.error!.message}');
      } else {
        print('Mesajlar başarıyla silindi.');
      }
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.username}',
          style: context.AppBarStyle,
        ), //Chat with ${widget.receiverUserId}
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                final roomId = await _roomIdFuture;
                setState(() {
                  deleteMessages(roomId);
                });
              },
              icon: Icon(Icons.delete))
        ],
      ),
      body: FutureBuilder<String>(
        future: _roomIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('error0: ${snapshot.error}');
            return Center(child: Text('Error0: ${snapshot.error}'));
          } else {
            final roomId = snapshot.data!;
            // _messageStream, roomId değiştikçe güncelleniyor
            _messageStream = AuthService().getMessages(roomId);

            return Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<Messages>>(
                    stream: _messageStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error1: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No messages yet.'));
                      } else {
                        final messages = snapshot.data!;
                        return ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMine =
                                message.senderId == widget.senderUserId;
                            return Align(
                              alignment: isMine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isMine
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  message.content,
                                  style: TextStyle(
                                    color: isMine ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          final roomId = await _roomIdFuture;
                          _sendMessage(roomId);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
