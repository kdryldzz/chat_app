import 'package:chat_app_1/helpers/database_helper.dart';
import 'package:chat_app_1/models/local_message.dart';
import 'package:chat_app_1/models/messages.dart';
import 'package:chat_app_1/models/rooms.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app_1/models/users.dart';

class GlobalController {
final supabase = Supabase.instance.client;
 Future<List<Users>> listUsers() async {
  try {
    final currentUser = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('users')
        .select()
        .neq('id', currentUser);

    if (response.isEmpty) {
      print("No users found.");
      return [];
    }

    return response.map((user) => Users.fromMap(user)).toList();
  } catch (e) {
    print('Error fetching users: $e');
    return [];
  }
}

Future<List<Rooms>> ListRooms()async{
 final currentUser = supabase.auth.currentUser!.id;
  try{
      final response = await supabase.from('rooms').select().or('user2_id.eq.$currentUser,user1_id.eq.$currentUser');
if(response.isEmpty){
  print("no rooms found");
  return[]; 
}
return response.map((room)=>Rooms.fromMap(room)).toList();

  }catch(e){
    print(e);
    return[];
  }
}

Future<List<Messages>> listMessages(String roomId) async {
  try {
    final response = await supabase
        .from('messages')
        .select() // Include the seen field
        .eq('room_id', roomId);

    if (response.isEmpty) {
      print("No messages found.");
      return [];
    }

    return response.map((message) => Messages.fromMap(message)).toList();
  } catch (e) {
    print('Error fetching messages: $e');
    return [];
  }
}

Future<String> getReceiverUserId(String roomId) async {
  final currentUser = supabase.auth.currentUser!.id;
  final response = await supabase
      .from('rooms')
      .select()
      .eq('room_id', roomId)
      .single();

 if(response.isEmpty){
  print("no receiver user id  found");
  return'';
}

  return response['user1_id'] == currentUser ? response['user2_id'] : response['user1_id'];
}

Future<void> sendMessage(String content, String roomId) async {
  final currentUser = supabase.auth.currentUser!.id;
  final receiverUserId = await getReceiverUserId(roomId);
  try {
    final response = await supabase
        .from('messages')
        .insert({
          'content': content,
          'senderUser_id': currentUser,
          'receiverUser_id': receiverUserId,
          'room_id': roomId,
          'created_at': DateTime.now().toIso8601String(),
        });

    if (response.isEmpty) {
      throw Exception('Error sending message');
    }
  } catch (e) {
    print('Error sending message: $e');
  }
}

Future<String> getOrCreateRoom(String userId) async {
  final currentUser = supabase.auth.currentUser!.id;
  try {
    // Check if a room already exists between the two users
    final response = await supabase
        .from('rooms')
        .select('room_id') // Ensure the correct column name is used
        .or('and(user1_id.eq.$currentUser,user2_id.eq.$userId),and(user1_id.eq.$userId,user2_id.eq.$currentUser)')
        .limit(1)
        .maybeSingle();

    if (response == null) {
      // If no room exists, create a new one
      final createResponse = await supabase
          .from('rooms')
          .insert({
            'user1_id': currentUser,
            'user2_id': userId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('room_id') // Ensure the correct column name is used
          .single();
      return createResponse['room_id'];
    }

    // Return the existing room ID
    return response['room_id'];
  } catch (e) {
    print('Error getting or creating room: $e');
    return '';
  }
}

Future<String> getOtherUsername(String roomId) async {
  final currentUser = supabase.auth.currentUser!.id;
  final response = await supabase
      .from('rooms')
      .select('user1_id, user2_id')
      .eq('room_id', roomId)
      .single();

  final otherUserId = response['user1_id'] == currentUser
      ? response['user2_id']
      : response['user1_id'];

  final userResponse = await supabase
      .from('users')
      .select('username')
      .eq('id', otherUserId)
      .single();

  return userResponse['username'];
}

Future<String> getOtherUserId(String roomId) async {
  final currentUser = supabase.auth.currentUser!.id;
  final response = await supabase
      .from('rooms')
      .select('user1_id, user2_id')
      .eq('room_id', roomId)
      .single();

  final otherUserId = response['user1_id'] == currentUser
      ? response['user2_id']
      : response['user1_id'];

  return otherUserId;
}




Future<String> getOtherAvatarUrl(String roomId) async {
  final currentUser = supabase.auth.currentUser!.id;
  final response = await supabase
      .from('rooms')
      .select('user1_id, user2_id')
      .eq('room_id', roomId)
      .single();

  final otherUserId = response['user1_id'] == currentUser
      ? response['user2_id']
      : response['user1_id'];

  final userResponse = await supabase
      .from('users')
      .select('avatar_url')
      .eq('id', otherUserId)
      .single();

  return userResponse['avatar_url'];
}

Future<void> deleteMessageFromSupabase(String messageId) async {
  try {
    final response = await supabase.from('messages').delete().eq('message_id', messageId);

    if (response.error != null) {
      print('Error deleting message from Supabase: ${response.error!.message}');
    } else {
      print('Message $messageId deleted from Supabase');
    }
  } catch (e) {
    print('Error deleting message from Supabase: $e');
  }
}
  Future<void> markMessagesAsSeen(String roomId) async {
    final currentUser = supabase.auth.currentUser!.id;
    try {
      final unseenMessages = await supabase
          .from('messages')
          .select('message_id')
          .eq('room_id', roomId)
          .eq('receiverUser_id', currentUser);

      for (var message in unseenMessages) {
        await deleteMessageFromSupabase(message['message_id']);
      }

      print('Mesajlar silindi ve local database\'e kaydedildi.');
    } catch (e) {
      print('Error marking messages as seen: $e');
    }
  }

  Future<List<LocalMessage>> loadMessages(String roomId) async {
  try {
    final unseenMessages = await listMessages(roomId);
    List<LocalMessage> messages = [];

    for (var message in unseenMessages) {
      bool exists = await DatabaseHelper().messageExists(message.message_id);
      if (!exists) {
        await DatabaseHelper().insertMessage(LocalMessage(
          messageId: message.message_id,
          senderUserId: message.senderUser_id,
          receiverUserId: message.receiverUser_id,
          roomId: message.room_id,
          content: message.content,
          createdAt: message.created_at,
        ));
      }
    }

    messages = await DatabaseHelper().getMessages(roomId);
    return messages; // Mesajları döndür
  } catch (e) {
    print('Error loading messages: $e');
    return [];
  }
}
Future<void> justDeleteMessagesSupabase(String room_id)async{
if(room_id.isNotEmpty){
  try{
   await supabase.from('messages').delete().eq('room_id', room_id);
  }
catch(e){
print('error : $e');
}
}
}

}

