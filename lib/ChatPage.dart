import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chatapp/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final String receriverEmail;
  final String receiverUID;

  const ChatPage(
      {Key? key, required this.receriverEmail, required this.receiverUID})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
  String time = "";

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await fetchTime();
      String temp = _messageController.text;
      await _chatService.sendMessage(widget.receiverUID, temp);
    }
    _messageController.clear();
  }

  Future<void> fetchTime() async {
    try {
      final Uri apiUrl = Uri.parse(
          'https://timeapi.io/api/Time/current/zone?timeZone=Asia/Jakarta');

      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          time = data['time'];
        });
        time = data['time'];
      } else {
        print('Failed to load time: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching time: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.receriverEmail)),
        body: Container(
          constraints: BoxConstraints.expand(), // Make the container fullscreen
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_2sr1UdObqOX_N7MW1zzW__WcibKM4KdSmg&usqp=CAU'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: _buildMessageList(),
              ),
              _buildMessageInput(),
            ],
          ),
        ));
  }

  Widget _buildMessageInput() {
    return Row(children: [
      Expanded(
          child: TextField(
        obscureText: false,
        controller: _messageController,
        decoration: const InputDecoration(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            fillColor: Colors.white,
            filled: true,
            hintText: 'Write Your Message..',
            hintStyle: TextStyle(color: Colors.grey)),
      )),
      IconButton(
        onPressed: sendMessage,
        icon: Icon(Icons.send_sharp),
        iconSize: 30,
        color: Colors.blue,
      )
    ]);
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var position =
        (data['senderId'] == _firebaseAuth.currentUser!.uid) ? true : false;

    var color = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Colors.blue
        : Colors.orange;

    return Container(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
            crossAxisAlignment:
                (data['senderId'] == _firebaseAuth.currentUser!.uid)
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            mainAxisAlignment:
                (data['senderId'] == _firebaseAuth.currentUser!.uid)
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              Text(data['senderEmail']),
              BubbleSpecialThree(
                text: data['message'],
                color: color,
                tail: position,
                isSender: position,
                textStyle: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(data['time'].toString())
            ]),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.receiverUID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        return ListView(
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }
}
