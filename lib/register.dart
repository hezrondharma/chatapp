import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController getUsername = TextEditingController();
  final TextEditingController getPassword = TextEditingController();

  List<Map<String, String>> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.5,
                  child: TextField(
                    controller: getUsername,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.5,
                  child: TextField(
                    controller: getPassword,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _registerUser();
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    try {
      String username = getUsername.text;
      String password = getPassword.text;

      DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");

      // Check if the username already exists
      DatabaseEvent event = await usersRef.orderByChild("username").equalTo(username).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        // Username already exists, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username already exists.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Username is unique, proceed with registration
        DatabaseReference newUserRef = usersRef.push();

        await newUserRef.set({
          "username": username,
          "password": password,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registered'),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context);
      }
    } catch (error) {
      print("Error registering user: $error");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to register user.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

}
