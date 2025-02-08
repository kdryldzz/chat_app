import 'package:chat_app_1/models/messages.dart';
import 'package:chat_app_1/models/rooms.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app_1/models/users.dart';

class SearchScreenController {
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
        .select()
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

Future<String> createRoom(String userId) async {
  final currentUser = supabase.auth.currentUser!.id;
  try {
    final response = await supabase
        .from('rooms')
        .insert({
          'user1_id': currentUser,
          'user2_id': userId,
        })
        .select()
        .single();


    return response['id'];
  } catch (e) {
    print('Error creating room: $e');
    return '';
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

}