import 'package:chatapp/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var time = "";

  Future<String> fetchTime() async {
    try {
      final Uri apiUrl = Uri.parse(
          'https://timeapi.io/api/Time/current/zone?timeZone=Asia/Jakarta');

      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        return data['time'];
      } else {
        print('Failed to load time: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching time: $error');
    }

    return 'buss';
  }

  Future<void> sendMessage(String receriverId, String message) async {
    // ignore: avoid_print
    print(fetchTime());
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentEmail = _firebaseAuth.currentUser!.email.toString();

    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentEmail,
        receiverId: receriverId,
        message: message,
        timestamp: Timestamp.now(),
        time: await fetchTime());

    List<String> ids = [currentUserId, receriverId];
    ids.sort();
    String chatRoomId = ids.join("-");

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("-");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
