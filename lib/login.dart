import 'package:chatapp/firebase_auth_services.dart';
import 'package:chatapp/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController getEmail = TextEditingController();
  final TextEditingController getPassword = TextEditingController();

  List<Map<String, String>> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: TextField(
                    controller: getEmail,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: TextField(
                    controller: getPassword,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _userLogin(context);
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _userLogin(BuildContext context) async {
    String email = getEmail.text;
    String password = getPassword.text;

    final authService =
        Provider.of<FirebaseAuthService>(context, listen: false);

    QuerySnapshot query = await FirebaseFirestore.instance.collection('users')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();

    if (query.docs.length == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect Email or Password'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      try {
        await authService.signInWithEmailAndPassword(email, password);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => LandingPage(recieved_email: email)));

    }
  }
}
