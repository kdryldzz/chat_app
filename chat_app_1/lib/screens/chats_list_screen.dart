import 'package:chat_app_1/controllers/search_screen_provider.dart';
import 'package:chat_app_1/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_1/models/rooms.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  SupabaseClient _supabase = Supabase.instance.client;
  final SearchScreenController _controller = SearchScreenController();
  late Future<List<Rooms>> _roomsFuture;
  String query = '';
  int unseenMessageNumber =0;

  @override
  void initState() {
    super.initState();
    _roomsFuture = _controller.ListRooms();

  }
Future<void> confirmAndDeleteRoom(BuildContext context, String roomId) async {
  if (roomId.isNotEmpty) {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Odayı Sil"),
          content: Text("Bu odayı silmek istediğinize emin misiniz(oda 2 kullanıcıdan da silinecektir)?"),
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
        await Supabase.instance.client
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


Future<void> countUnseenMessages(String roomId) async {
  final currentUser = _supabase.auth.currentUser!.id;
  try {
    final unseenMessages = await _supabase.from('messages').select('message_id').eq('receiverUser_id', currentUser).eq('room_id', roomId).eq('seen', false); 
      unseenMessageNumber = unseenMessages.length;
  } catch (e) {
    debugPrint('Error counting unseen messages: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background2.jpg'), // Arka plan resmi
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding:  EdgeInsets.all(8.0.w),
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
                                  subtitle: Text('Room ID: ${room.room_id}'),
                                  trailing: IconButton(onPressed: (){
                                  confirmAndDeleteRoom(context,room.room_id);
                                  }, icon: Icon(Icons.delete)),
                                );
                              } else if (userSnapshot.hasError) {
                                return ListTile(
                                  title: Text('Error'),
                                  subtitle:Text('Room ID: ${room.room_id}'),
                                  trailing: IconButton(onPressed: (){
                                    confirmAndDeleteRoom(context,room.room_id);
                                  }, icon: Icon(Icons.delete)),
                                );
                              } else {
                                final username = userSnapshot.data!;
                                return FutureBuilder<String>(
                                  future: _controller.getOtherAvatarUrl(room.room_id),  // Kullanıcının avatar_url'sini alıyoruz
                                  builder: (context, avatarSnapshot) {
                                    String avatarUrl = 'https://e7.pngegg.com/pngimages/84/165/png-clipart-united-states-avatar-organization-information-user-avatar-service-computer-wallpaper.png';  // Varsayılan avatar
                                    countUnseenMessages(room.room_id); 
                                    if (avatarSnapshot.connectionState == ConnectionState.done && avatarSnapshot.hasData) {
                                      avatarUrl = avatarSnapshot.data!;  
                                      // Avatar URL varsa, onu kullanıyoruz 
                                    }
                                    // Username'a göre arama işlemi
                                    if (username.toLowerCase().contains(query.toLowerCase())) {
                                      countUnseenMessages(room.room_id); 
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(avatarUrl), // Kullanıcı avatar URL'si
                                        ),
                                        title: Text(username),
                                        subtitle: 
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(20)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 15),
                                            child: Text("$unseenMessageNumber new messages"),
                                          ), // Yeni mesaj sayısı
                                        ),
                                        trailing: IconButton(onPressed: (){
                                          confirmAndDeleteRoom(context,room.room_id);
                                        }, icon: Icon(Icons.delete)),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChatScreen(roomId: room.room_id),
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      return Container(); // Eğer arama filtresine uymuyorsa, boş döndür
                                    }
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
      ),
    );
  }
}
