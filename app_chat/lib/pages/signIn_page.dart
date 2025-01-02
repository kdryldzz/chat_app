import 'package:app_chat/models/auth_service.dart';
import 'package:app_chat/pages/chats.dart';
import 'package:app_chat/pages/register.dart';
import 'package:app_chat/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SigninPage extends StatefulWidget {
  SigninPage({super.key});
  static const String path = '/sign_in_page';
  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void login() async {
//prepare data
    final email = _emailController.text;
    final password = _passwordController.text;

//attempt to login

    try {
      await authService.signInWithEmailPassword(email, password);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("login successfull"),
          backgroundColor: Colors.green,
        ),
      );
      context.go(Chats.path);
    }
//catch errors
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("error-0 : $e")));
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome To ChatApp",
          style: context.AppBarStyle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                width: 220,
                height: 220,
                child: Image.asset("images/logo.png"),
              ),
              settingsTextFormField(
                Controller: _emailController,
                labelText: "email:",
              ),
              SizedBox(height: 10),
              settingsTextFormField(
                Controller: _passwordController,
                labelText: "password:",
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.Color1,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text('login', style: context.buttonTextStyle),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.go(Register.path);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.Color1,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text('register', style: context.buttonTextStyle),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class settingsTextFormField extends StatelessWidget {
  const settingsTextFormField({
    super.key,
    required this.Controller,
    required this.labelText,
  });

  final TextEditingController Controller;
  final String labelText;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: TextFormField(
        controller: Controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }
}
