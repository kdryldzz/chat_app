import 'package:chat_app_1/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  String? userEmail;
  String? userName;
  String? avatarUrl;

  // Rastgele profil fotoğrafı linki almak için kullanılan API
  Future<String> _getRandomAvatar() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'][0]['picture']['large']; // Avatar linki
    } else {
      throw Exception('Failed to load avatar');
    }
  }

  // Kullanıcı bilgilerini Supabase'ten almak
  Future<void> _loadUserData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final response = await _supabase
          .from('users')
          .select('username, avatar_url') // Kullanıcı adı ve avatar_url aldık
          .eq('id', user.id)
          .single();

      if (response.isNotEmpty) {
        setState(() {
          userName = response['username'] ?? 'User';
          userEmail = user.email;
          avatarUrl = response['avatar_url']; // Avatar URL
        });
      } else {
        setState(() {
          userName = 'User';
          userEmail = 'Loading...';
          avatarUrl = 'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'; // Varsayılan avatar
        });
      }
    }
  }

  // Profil fotoğrafını değiştirmek için Supabase'e kaydetmek
  Future<void> _updateAvatar() async {
    try {
      String randomAvatar = await _getRandomAvatar();
      final user = _supabase.auth.currentUser;
      
      if (user != null) {
        final response = await _supabase
            .from('users')
            .update({'avatar_url': randomAvatar}) // Yeni avatar linki
            .eq('id', user.id);
        
        if (response.error == null) {
          setState(() {
            avatarUrl = randomAvatar; // Avatar URL güncellendi
          });
        } else {
          print('Error updating avatar: ${response.error?.message}');
        }
      }
    } catch (e) {
      print('Error fetching random avatar: $e');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    userName;
    userEmail;
    avatarUrl;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Kullanıcı bilgilerini yükle
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 9.0,
                color: Colors.black45,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(avatarUrl ?? 'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.deepPurple),
                onPressed:()async{
                  await _updateAvatar();
                  setState(() {
                    _loadUserData();
                  });
                }, // Butona tıklayınca avatar güncelleniyor
              ),
              const SizedBox(height: 20),
              Text(
                userName ?? 'Loading...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                userEmail ?? 'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 60),
              Card(
                color: Colors.white.withOpacity(0.8),
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: Icon(Icons.email, color: Colors.deepPurple),
                  title: const Text('Email'),
                  subtitle: Text(userEmail ?? 'Loading...'),
                ),
              ),
              const SizedBox(height: 60),
              Consumer<AuthProvider>(builder: (context, value, child) {
                return ElevatedButton(
                  onPressed: () {
                    value.logout(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
