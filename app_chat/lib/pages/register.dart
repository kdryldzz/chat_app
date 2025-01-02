import 'package:app_chat/models/auth_service.dart';
import 'package:app_chat/pages/signIn_page.dart';
import 'package:app_chat/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  static const String path = '/register_page';

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final authService = AuthService();
//text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

//signUp button pressed
  void signUp() async {
// prepare data
    final email = _emailController.text;
    final password = _passwordController.text;
    final confimPassword = _confirmPasswordController.text;

    if (password != confimPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("passwords are different")));
      return;
    }

    // attemt to register
    try {
      await authService.signUpWithEmailPassword(email, password);
      context.go(SigninPage.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("register error : $e")));
      }
    }
  }

  void registerUser() async {
    final supabase = Supabase.instance.client;
    //prepare data
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // does match password and confirm passwordd
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("your passwords aren't equals")));
      _passwordController.clear();
      _confirmPasswordController.clear();
      return;
    }

    // attempt register
    try {
      final response =
          await supabase.auth.signUp(email: email, password: password);
      await authService.registerUser(username, email, password);
      await ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Register succesfully completed :)",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));

      final userId = response.user!.id;

      // users tablosuna ekleme
      await supabase.from('users').insert({
        'id': userId, // Foreign key
        'username': username,
        'email': email,
        'password': password
      });
      context.go(SigninPage.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("error: $e")));
        print("errror messsage: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "REGISTER",
          style: context.AppBarStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.go(SigninPage.path);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'images/logo.png',
                  height: 180,
                  width: 180,
                ),
                const SizedBox(height: 20),
                settingsTextFormField(
                  controller: _usernameController,
                  labelText: "Username:",
                ),
                SizedBox(height: 20),
                settingsTextFormField(
                  controller: _emailController,
                  labelText: "Email:",
                ),
                SizedBox(height: 20),
                settingsTextFormField(
                  controller: _passwordController,
                  labelText: "Password:",
                ),
                const SizedBox(height: 20),
                settingsTextFormField(
                  controller: _confirmPasswordController,
                  labelText: "Confirm Password:",
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.Color1,
                    padding: EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Register', style: context.buttonTextStyle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class settingsTextFormField extends StatelessWidget {
  const settingsTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    //  required this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  // final validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      // validator: validator,
    );
  }
}
