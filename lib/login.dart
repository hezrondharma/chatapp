import 'package:chatapp/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'friend_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuthService _auth = FirebaseAuthService();
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

    DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");

    DatabaseEvent event = await usersRef.once();

    if (event.snapshot != null && event.snapshot.value != null) {
      Map<dynamic, dynamic> usersData = Map.from(event.snapshot.value as Map<dynamic, dynamic>);
      User?user =  await _auth.signInWithEmailAndPassword(email, password);
      // bool isUserRegistered = usersData.values.any(
      //       (user) => user['email'] == email && user['password'] == password,
      // );

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil'),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FriendList(email: email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login gagal.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Handle jika data kosong atau terjadi kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat mengambil data pengguna.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

}
