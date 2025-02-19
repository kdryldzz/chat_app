import 'dart:io';
import 'package:chat_app_1/controllers/global_controller.dart';
import 'package:chat_app_1/helpers/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_1/models/local_message.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  const ChatScreen({super.key, required this.roomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  final GlobalController _controller = GlobalController();
  late Future<String> _otherUsernameFuture;
  final TextEditingController _messageController = TextEditingController();
  final String currentUser = Supabase.instance.client.auth.currentUser!.id;
  final SupabaseClient _supabase = Supabase.instance.client;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<LocalMessage> _messages = [];
  ScrollController _scrollController = ScrollController(); // ScrollController ekledik


  @override
  void initState() {
    super.initState();
    _otherUsernameFuture = _controller.getOtherUsername(widget.roomId);
    _loadMessages();
    _controller.markMessagesAsSeen(widget.roomId);

    // Mesajlar geldiğinde kaydırmayı en alta yap
    _supabase
        .from('messages')
        .stream(primaryKey: ['message_id'])
        .eq('room_id', widget.roomId)
        .listen((List<Map<String, dynamic>> messages) {
      if (messages.isNotEmpty) {
        print("Yeni mesaj alındı: ${messages.last}");
        _loadMessages();
      }
    });
  }

  Future<void> _loadMessages() async {
    final messages = await _controller.loadMessages(widget.roomId);
    setState(() {
      _messages = messages;
    });
    // Mesajlar yüklendikten sonra kaydırmayı en alta yap
    _scrollToBottom();
  }

  Future<void> _deleteMessagesAsRoomId(String roomId) async {
  if (roomId.isNotEmpty) {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Mesajları Sil"),
          content: Text("Bu odadaki tüm mesajları silmek istediğinize emin misiniz?"),
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
        await _databaseHelper.deleteMessages(roomId);
        await _controller.justDeleteMessagesSupabase(roomId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Mesajlar başarıyla silindi!")),
          );
        }
        setState(() {
          _loadMessages();
        });
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Mesajlar silinirken hata oluştu: $e")),
          );
        }
      }
    }
  }
}
 // load image to supabase
   File? _imageFile;
//pick image
Future pickImage()async{
//picker
ImagePicker picker = ImagePicker();

final XFile? image = await picker.pickImage(source: ImageSource.gallery);

if(image != null){
 setState(() {
   _imageFile = File(image.path);
 });
}}

// upload
  Future uploadImage() async {
    if (_imageFile == null) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.path.split('/').last}';
    final path = 'uploads/${widget.roomId}/$fileName';

    // upload the image to supabase storage
    final response = await _supabase.storage
        .from('chat_images')
        .upload(path, _imageFile!);

    if (response.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image upload is successful")));
      // reload user data to update the UI
      await  _loadMessages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image upload failed:")));
    }
  }

  // Kaydırmayı en alta yapacak fonksiyon
  void _scrollToBottom() {
    // Mesajlar geldikçe kaydırmayı kontrol et
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300), // 300ms içinde kaydır
        curve: Curves.easeInOut, // Kaydırmanın animasyonu
      );
    }
  }
  @override
  void dispose() {
    _supabase.removeAllChannels();
    _scrollController.dispose(); // Controller'ı dispose ediyoruz
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w),
              child: AppBar(
                backgroundColor: Colors.transparent, // Saydam arka plan
                elevation: 0, // Gölgeyi kaldır
                title: FutureBuilder<String>(
                  future: _otherUsernameFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    } else if (snapshot.hasError) {
                      return Text('Error');
                    } else {
                      return Text(
                        snapshot.data!.toUpperCase(),
                        style: TextStyle(
                          color: Colors.black, // Başlık rengi beyaz
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  },
                ),
                centerTitle: true,
                toolbarHeight: 30.h, // Daha geniş AppBar
                actions: [IconButton(onPressed:(){
                  _deleteMessagesAsRoomId(widget.roomId); // this method deletes only seen messages
                }, icon: Icon(Icons.delete))],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // Controller'ı ListView'e ekledik
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isCurrentUser = message.senderUserId == currentUser;
                  return Align(
                    alignment:
                        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                      margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                      decoration: BoxDecoration(
                        color: isCurrentUser ? Colors.blue[200] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.content,
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            message.createdAt.toLocal().toString(),
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0.w),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0.r),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  IconButton(onPressed:()async{
                    await pickImage();
                    await uploadImage();
                    setState(() {
                      _loadMessages();
                    });
                  }, icon: Icon(Icons.photo_camera)),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      if (_messageController.text.isNotEmpty) {
                        await _controller.sendMessage(
                            _messageController.text, widget.roomId,"imageee");
                        _messageController.clear();
                        _loadMessages();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
