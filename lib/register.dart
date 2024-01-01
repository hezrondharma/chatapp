import 'package:chatapp/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

GlobalKey<FormState> _formKey = GlobalKey<FormState>();
class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}class _RegisterState extends State<Register> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController getEmail = TextEditingController();
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextFormField(
                      controller: getEmail,
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address.';
                        }
                        if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextFormField(
                      controller: getPassword,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Check if the form is valid
                      if (_formKey.currentState?.validate() ?? false) {
                        // If valid, proceed with registration
                        _registerUser();
                      }
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    try {
      String email = getEmail.text;
      String password = getPassword.text;

      DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");

      // Check if the username already exists
      DatabaseEvent event = await usersRef.orderByChild("email").equalTo(email).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        // Username already exists, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email already exists.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        User?user =  await _auth.signUpWithEmailAndPassword(email, password);
        // // Username is unique, proceed with registration
        DatabaseReference newUserRef = usersRef.push();

        await newUserRef.set({
          "email": email,
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
