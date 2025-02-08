import 'package:chat_app_1/layouts/bottom_navbar_layout.dart';
import 'package:chat_app_1/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  //register function
  Future<void> register(String username, String email, String password, BuildContext context) async {
    try {
      final response = await _supabase.auth.signUp(password: password, email: email);
      final currentId = response.user!.id;
      if (response.user != null) {
        await _supabase.from('users')
            .insert([{
          'id': currentId,
          'username': username,
          'email': email,
          'password': password,
        }]).select();

        notifyListeners(); // Notify listeners after successful registration

        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavbarLayout()),
        );
      }
    } on AuthException catch (e) {
      debugPrint('Authentication error: ${e.message}');
      // show error message
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Unexpected error: $e');
      // show error message
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('An unexpected error occurred'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> login(String email, String password, BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      //show error message
      showDialog(context: context, builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Please fill in all fields'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ));
      return;
    } else {
      try {
        final response = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null) {
          notifyListeners(); // Notify listeners after successful login

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavbarLayout()),
          );
        }
      } on AuthException catch (e) {
        print('Authentication error: ${e.message}');

        //show error message
        showDialog(context: context, builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ));
      } catch (e) {
        print('Unexpected error: $e');

        //show error message
        showDialog(context: context, builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('An unexpected error occurred'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ));
      }
    }
  }

  //logout function
  Future<void> logout(BuildContext context) async {
    try {
      await _supabase.auth.signOut();

      notifyListeners(); // Notify listeners after successful logout

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print('Unexpected error: $e');
    }
  }
}