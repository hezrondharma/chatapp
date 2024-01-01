import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chatapp/ChatPage.dart';
class FriendList extends StatefulWidget {
  final String email;

  const FriendList({Key? key, required this.email}) : super(key: key);

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  List<bool> isPlayingList = List.generate(7, (index) => false);
  List<double> musicRatings = List.generate(7, (index) => 3.0);
  List<String> friendsList = []; // Updated to store the list of friends
  @override
  void initState() {
    super.initState();
    _fetchFriendsList(); // Fetch the list of friends when the widget initializes
  }

  Future<void> _fetchFriendsList() async {
    try {
      DatabaseReference friendsRef = FirebaseDatabase.instance.ref("friends");

      DatabaseEvent event = await friendsRef
          .orderByChild("myemail")
          .equalTo(widget.email)
          .once();

      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        // Friends found, update the friendsList
        setState(() {
          friendsList = (snapshot.value as Map<dynamic, dynamic>).values
              .map<String>((friend) => friend['email'] as String)
              .toList();
        });
      }
    } catch (error) {
      print("Error fetching friends list: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<bool> chatButtonList = List.generate(friendsList.length, (index) => false);

// Inside your build method:
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Welcome, ${widget.email}'),
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              _showAddFriendDialog();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < friendsList.length; i++)
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _handleChatButtonPress(friendsList[i]);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: chatButtonList[i] ? Colors.red : Colors.green,
                                minimumSize: Size(MediaQuery.of(context).size.width * 0.5, 0),
                              ),
                              child: Text('Chat'),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              friendsList[i],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
              onPressed: () {
                _addFriend(widget.email, newEmail);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
  void _handleChatButtonPress(String friendEmail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          myEmail: widget.email,
          friendEmail: friendEmail,
        ),
      ),
    );
  }
  void _addFriend(String myEmail, String newEmail) async {
    try {
      if (newEmail == myEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot add yourself as a friend.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      DatabaseReference users = FirebaseDatabase.instance.ref("users");
      DatabaseReference friendsRef = FirebaseDatabase.instance.ref("friends");
      DatabaseEvent emailExist = await users.orderByChild("email").equalTo(newEmail).once();
      DatabaseEvent myemail = await friendsRef.orderByChild("myemail").equalTo(myEmail).once();
      DatabaseEvent OtherEmail = await friendsRef.orderByChild("email").equalTo(newEmail).once();
      DataSnapshot snapshot = myemail.snapshot;
      DataSnapshot datashot = OtherEmail.snapshot;
      DataSnapshot Exist = emailExist.snapshot;

      if (Exist.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('email not found'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if (snapshot.value != null) {
        if (datashot.value != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('you already Friend with this email'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      DatabaseReference newFriendRef = friendsRef.push();

      await newFriendRef.set({
        "myemail": myEmail,
        "email": newEmail,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print("Error adding friend: $error");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add friend.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}


