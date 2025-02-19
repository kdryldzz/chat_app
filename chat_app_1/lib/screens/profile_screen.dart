import 'dart:io';
import 'package:chat_app_1/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}

}
  // upload
  Future uploadImage() async {
    if (_imageFile == null) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.path.split('/').last}';
    final path = 'uploads/${user.id}/$fileName';

    // upload the image to supabase storage
    final response = await _supabase.storage
        .from('images')
        .upload(path, _imageFile!);

    if (response.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image upload is successful")));

      await _supabase.from('users').update({'avatar_url': fileName}).eq('id', user.id);

      // reload user data to update the UI
      _loadUserData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image upload failed:")));
    }
  }
  @override
  void dispose() {
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
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
            shadows: [
              Shadow(
                blurRadius: 9.0.r,
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
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100.h),
            CircleAvatar(
              radius: 50.r,
              backgroundImage: NetworkImage(
                avatarUrl != '' && avatarUrl != null
                    ? 'https://wjxfpnsrjsofhfstivls.supabase.co/storage/v1/object/public/images/uploads/${_supabase.auth.currentUser!.id}/$avatarUrl'
                    : 'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png',
              ),

            ),
            SizedBox(height: 20.h),
            ElevatedButton(onPressed: ()async{
              await pickImage();
              await uploadImage();
              setState(() {
                _loadUserData();
              });
            } , child: const Text("Edit")),
            SizedBox(height: 20.h),
            Text(
              userName ?? 'Loading...',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 15.h),
            Text(
              userEmail ?? 'Loading...',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 60.h),
            Card(
              color: Colors.white.withOpacity(0.8),
              margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: ListTile(
                leading: Icon(Icons.email, color: Colors.deepPurple),
                title: const Text('Email'),
                subtitle: Text(userEmail ?? 'Loading...'),
              ),
            ),
            SizedBox(height: 60.h),
            Consumer<AuthProvider>(builder: (context, value, child) {
              return ElevatedButton(
                onPressed: () {
                  value.logout(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
