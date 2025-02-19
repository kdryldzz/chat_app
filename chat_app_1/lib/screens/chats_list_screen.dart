import 'package:chat_app_1/controllers/global_controller.dart';
import 'package:chat_app_1/helpers/database_helper.dart';
import 'package:chat_app_1/models/local_message.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_1/models/rooms.dart';
import 'package:chat_app_1/screens/chat_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GlobalController _controller = GlobalController();
  late Future<List<Rooms>> _roomsFuture;
  String query = '';
 

 
  Future<void> confirmAndDeleteRoom(BuildContext context, String roomId) async {
    if (roomId.isNotEmpty) {
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Odayı Sil"),
            content: Text("Bu odayı silmek istediğinize emin misiniz (oda 2 kullanıcıdan da silinecektir)?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Hayır"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Evet"),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        try {
          await _supabase
              .from('rooms')
              .delete()
              .eq('room_id', roomId);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Oda başarıyla silindi!")),
            );
          }

          // Oda silindikten sonra listeyi güncelle
          setState(() {
            _roomsFuture = _controller.ListRooms();
          });
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Oda silinirken hata oluştu: $e")),
            );
          }
        }
      }
    }
  }


   String lastMessage = "";
 Future<String> fetchLastMessage(String roomId) async {
  try {
    // 🔹 Supabase'den son mesajı al
    final response = await _supabase
        .from('messages')
        .select('content, created_at')
        .eq('room_id', roomId)
        .order('created_at', ascending: false) // En güncel mesajı al
        .limit(1);

    String? supabaseMessage;
    DateTime? supabaseTime;

    if (response.isNotEmpty) {
      supabaseMessage = response[0]['content'];
      supabaseTime = DateTime.parse(response[0]['created_at']);
    }

    // 🔹 Lokal veritabanından son mesajı al (örneğin SQLite)
    final localMessage = await fetchLastLocalMessage(roomId);

    // 🔹 Karşılaştır ve en güncel mesajı döndür
    if (supabaseTime != null && localMessage != null) {
      return (supabaseTime.isAfter(localMessage.createdAt))
          ? supabaseMessage!
          : localMessage.content;
    } else if (supabaseMessage != null) {
      return supabaseMessage;
    } else if (localMessage != null) {
      return localMessage.content;
    } else {
      return "No messages";
    }
  } catch (e) {
    print("fetch last message error: $e");
    return "Error loading message";
  }
}
Future<LocalMessage?> fetchLastLocalMessage(String roomId) async {
  final db = await DatabaseHelper.instance.database;
  final result = await db.query(
    'messages',
    where: 'room_id = ?',
    whereArgs: [roomId],
    orderBy: 'created_at DESC', // En son mesajı al
    limit: 1,
  );

  if (result.isNotEmpty) {
    return LocalMessage.fromMap(result.first);
  } else {
    return null;
  }
}

   @override
  void initState() {
    super.initState();
    _roomsFuture = _controller.ListRooms();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30.h), // Yükseklik düzenlemesi
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w), // Padding
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search', // Arama kutusu
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
              child: FutureBuilder<List<Rooms>>(
                future: _roomsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error.toString()}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No chat found'));
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
                                subtitle: Center(),
                                trailing: IconButton(
                                  onPressed: () {
                                    confirmAndDeleteRoom(context, room.room_id);
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              );
                            } else if (userSnapshot.hasError) {
                              return ListTile(
                                title: Text('Error'),
                                subtitle: Center(),
                                trailing: IconButton(
                                  onPressed: () {
                                    confirmAndDeleteRoom(context, room.room_id);
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              );
                            } else {
                              final username = userSnapshot.data!;
                              return FutureBuilder<String>(
                                future: _controller.getOtherAvatarUrl(room.room_id), // Kullanıcının avatar_url'sini alıyoruz
                                builder: (context, avatarSnapshot) {
                                  String avatarUrl = 'https://e7.pngegg.com/pngimages/84/165/png-clipart-united-states-avatar-organization-information-user-avatar-service-computer-wallpaper.png'; // Varsayılan avatar
                                  if (avatarSnapshot.connectionState == ConnectionState.done && avatarSnapshot.hasData) {
                                    avatarUrl = avatarSnapshot.data!; // Avatar URL varsa, onu kullanıyoruz
                                  }
                                  return FutureBuilder<String>(
                                    future: fetchLastMessage(room.room_id),
                                    builder: (context, lastMessageSnapshot) {
                                      if (lastMessageSnapshot.connectionState == ConnectionState.waiting) {
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(""), // Kullanıcı avatar URL'si
                                          ),
                                          title: Text(username),
                                          subtitle: Text(''),
                                          trailing: IconButton(
                                            onPressed: () {
                                              confirmAndDeleteRoom(context, room.room_id);
                                            },
                                            icon: Icon(Icons.delete),
                                          ),
                                        );
                                      } else if (lastMessageSnapshot.hasError) {
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(avatarUrl), // Kullanıcı avatar URL'si
                                          ),
                                          title: Text(username),
                                          subtitle: Text('Error loading last message'),
                                          trailing: IconButton(
                                            onPressed: () {
                                              confirmAndDeleteRoom(context, room.room_id);
                                            },
                                            icon: Icon(Icons.delete),
                                          ),
                                        );
                                      } else {
                                        final lastMessage = lastMessageSnapshot.data;
                                        return FutureBuilder<String>(
                                          future: _controller.getOtherUserId(room.room_id),
                                          builder: (context, otherUserIdSnapshot) {
                                            final userId = otherUserIdSnapshot.data;
                                            return FutureBuilder<int>(
                                              future: _controller.countUnseenMessages(room.room_id),
                                              builder: (context, unseenMessagesSnapshot) {
                                               final  unseenMessageNumber = unseenMessagesSnapshot.data;
                                                return ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundImage: NetworkImage("https://wjxfpnsrjsofhfstivls.supabase.co/storage/v1/object/public/images/uploads/${userId}/${avatarUrl}"), // Kullanıcı avatar URL'si
                                                  ),
                                                  title: Text(username),
                                                  subtitle:
                                                  Text('$lastMessage',style: TextStyle(color: const Color.fromARGB(255, 51, 52, 51)),),
                                                  trailing: Container(
                                                    alignment: Alignment.center,
                                                    height: 30.h,
                                                    width: 30.w,
                                                    decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.circular(15),
                                                  ), child: Text("$unseenMessageNumber")
                                                  ), 
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ChatScreen(roomId: room.room_id),
                                                      ),
                                                    );
                                                  },
                                                  onLongPress:(){ 
                                                  print("long pressed");
                                                  } ,
                                                );
                                              }
                                            );
                                          }
                                        );
                                      }
                                    },
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
            ),
          ],
        ),
      ),
    );
  }
}