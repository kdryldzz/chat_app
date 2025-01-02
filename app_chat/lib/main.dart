import 'package:app_chat/models/router.dart';
import 'package:app_chat/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://tktxdgdlkeqzwsifjvux.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRrdHhkZ2Rsa2VxendzaWZqdnV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM2NjQzNjMsImV4cCI6MjA0OTI0MDM2M30.-irU9f50XQLbwz-CMD_LSou8wL6tUghspTOY6rJAA0c');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Tasarımınızın temel ekran boyutu
      minTextAdapt: true, // Yazı boyutlarını otomatik ayarla
      splitScreenMode: true, // Çoklu ekran desteği
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white).copyWith(
              surfaceContainerLow: context.Color1,
              surface: Colors.white,
            ),
            useMaterial3: true,
          ),
          routerConfig: router,
        );
      },
    );
  }
}
