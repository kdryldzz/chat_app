import 'package:chat_app_1/providers/auth_provider.dart';
import 'package:chat_app_1/services/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url:'https://wjxfpnsrjsofhfstivls.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndqeGZwbnNyanNvZmhmc3RpdmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU5MTczMTUsImV4cCI6MjA1MTQ5MzMxNX0.0QQAftf4GGaoi6zKPrDi3FXEJwYl4TPN1j5ixehh0Js'
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context)=>AuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: AuthGate(),
      ),
    );
  }
}

