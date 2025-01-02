/*  
AUTH GATE --> This will continuously listen for auth state changes

---------------------------------------------------------------------------

unauthenticated --> Login page
authenticated --> profile  page

*/
import 'package:app_chat/pages/chats.dart';
import 'package:app_chat/pages/signIn_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  static const path = "/auth_gate";

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,
      // Build appropiaate page based on auth state
      builder: (context, snapshot) {
        //loading..
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // check if there is a valid session currently
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return Chats();
        } else {
          return SigninPage();
        }
      },
    );
  }
}
