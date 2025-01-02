import 'package:app_chat/models/messages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

// register in with password and email
  Future<AuthResponse> signUpWithEmailPassword(
      String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }
//login with email and password

  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    return await _supabase.auth
        .signInWithPassword(email: email, password: password);
  }

//get current user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

//log out
  Future<void> signOut() async {
    return await _supabase.auth.signOut();
  }

// save registered user informations in users table
  Future<void> registerUser(
      String username, String email, String password) async {
    try {
      // Auth kaydı
      final response =
          await _supabase.auth.signUp(email: email, password: password);

      if (response.user == null) {
        throw Exception('Kullanıcı oluşturulamadı');
      }

      final userId = response.user!.id;

      // users tablosuna ekleme
      final insertResponse = await _supabase.from('users').insert({
        'id': userId, // Foreign key
        'username': username,
        'email': email,
        'password': password
      });

      if (insertResponse.error != null) {
        throw Exception(
            'Kullanıcı bilgileri kaydedilemedi: ${insertResponse.error!.message}');
      }

      print('Kayıt başarıyla tamamlandı.');
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<String> findOrCreateRoom(
      String senderUserId, String receiverUserId) async {
    // Oda arama sorgusu
    final response = await _supabase
        .from('rooms')
        .select('id') // Yalnızca ID değerini al
        .or('and(user1_id.eq.$senderUserId,user2_id.eq.$receiverUserId),and(user1_id.eq.$receiverUserId,user2_id.eq.$senderUserId)')
        .limit(1) // Sadece ilk sonucu döndür
        .maybeSingle();

    if (response == null) {
      // Oda bulunamazsa, yeni bir oda oluşturuyorum
      final insertResponse = await _supabase
          .from('rooms')
          .insert({
            'user1_id': senderUserId,
            'user2_id': receiverUserId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('id') // Odanın ID'sini geri alıyoruz
          .single();

      return insertResponse['id']; // Yeni oda ID'sini döndürüyoruz
    }

    // Var olan odanın ID'sini döndürüyoruz
    return response['id'];
  }

  Stream<List<Messages>> getMessages(String roomId) {
    return _supabase
        .from('messages') // 'messages' tablosunda sorgulama yapıyoruz
        .stream(primaryKey: ['id']) // 'id' anahtarını kullanıyoruz
        .eq('room_id', roomId) // 'room_id' ile filtreleme yapıyoruz
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => Messages.fromMap(e)).toList());
  }

  Future<void> sendMessage(
      String roomId, String senderId, String content) async {
    await _supabase.from('messages').insert({
      'sender_id': senderId,
      'created_at': DateTime.now().toIso8601String(),
      'room_id': roomId,
      'content': content,
    });
  }
}
