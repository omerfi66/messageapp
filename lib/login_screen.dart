import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:messageaoo/auth_provider.dart';
import 'package:messageaoo/home_screen.dart';
import 'package:messageaoo/signup_screen.dart';
import 'package:provider/provider.dart';

class LoginScreenState extends StatefulWidget {
  const LoginScreenState({super.key});

  @override
  State<LoginScreenState> createState() => __LoginScreenStateState();
}

class __LoginScreenStateState extends State<LoginScreenState> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Screen"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please Enter Email";
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please Enter password";
                }
                return null;
              },
            ),
            SizedBox(height: 50),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              height: 55,
              child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await authProvider.signIn(
                          _emailController.text, _passwordController.text);
                      Fluttertoast.showToast(msg: "Login Success");
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreenState(),
                          ));
                    } catch (e) {
                      print(e);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white),
                  child: Text(
                    'Log In',
                    style: TextStyle(fontSize: 18),
                  )),
            ),
            SizedBox(height: 20),
            Text('OR'),
            TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpScreenState(),
                      ));
                },
                child: Text(
                  'Create Account',
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ))
          ],
        ),
      ),
    );
  }
}
