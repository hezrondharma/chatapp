import 'package:chatapp/ChatPage.dart';
import 'package:chatapp/firebase_auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  final String recieved_email;
  final Key? key;

  const LandingPage({required this.recieved_email, this.key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void signOut() {
    final authService =
        Provider.of<FirebaseAuthService>(context, listen: false);
    authService.signOut;
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats'), actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            setState(() {
              _buildUserList();
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_add),
          onPressed: () {
            _showAddFriendDialog();
          },
        ),
        IconButton(
          onPressed: signOut,
          icon: const Icon(Icons.logout),
        )
      ]),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return Scaffold(
        body: Container(
            constraints:
                BoxConstraints.expand(), // Make the container fullscreen
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_2sr1UdObqOX_N7MW1zzW__WcibKM4KdSmg&usqp=CAU'),
                fit: BoxFit.cover,
              ),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading..");
                }

                return ListView(
                  children: snapshot.data!.docs
                      .map<Widget>(
                        (doc) => FutureBuilder<Widget>(
                          future: _buildUserListItem(doc),
                          builder: (context, userItemSnapshot) {
                            return userItemSnapshot.data ??
                                const SizedBox(); // Replace with your default Widget if needed
                          },
                        ),
                      )
                      .toList(),
                );
              },
            )));
  }

  Future<Widget> _buildUserListItem(DocumentSnapshot document) async {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userlist')
        .where('receivedEmail', isEqualTo: data['email'])
        .where('senderEmail', isEqualTo: widget.recieved_email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      Map<String, dynamic> userData =
          documentSnapshot.data() as Map<String, dynamic>;

      if (userData['receivedEmail'] == data['email']) {
        return ListTile(
          title: Text(data['email'].toString()),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receriverEmail: data['email'],
                  receiverUID: data['uid'],
                ),
              ),
            );
          },
        );
      } else {
        return const SizedBox(); // or any other default Widget
      }
    } else {
      return const SizedBox(); // or any other default Widget
    }
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newEmail = '';

        return AlertDialog(
          title: const Text('Add Friend'),
          content: TextField(
            onChanged: (value) {
              newEmail = value;
            },
            decoration: const InputDecoration(labelText: 'Friend\'s Email'),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                _addFriend(widget.recieved_email, newEmail);
                await Future.delayed(Duration(seconds: 2));
                setState(() {
                  _buildUserList();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addFriend(String senderEmail, String recievedEmail) async {
    CollectionReference userlistCollection =
        FirebaseFirestore.instance.collection('userlist');

    if (senderEmail == recievedEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot add your own email!!!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      QuerySnapshot recieverChecker = await FirebaseFirestore.instance
          .collection('userlist')
          .where('receivedEmail', isEqualTo: recievedEmail)
          .where('senderEmail', isEqualTo: senderEmail)
          .get();
      if (recieverChecker.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Already befriended with this email!!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        QuerySnapshot userRegistered = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: recievedEmail)
            .get();
        if (userRegistered.docs.isNotEmpty) {
          await userlistCollection.add({
            'senderEmail': senderEmail,
            'receivedEmail': recievedEmail,
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email Not Registered!!!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }
}
