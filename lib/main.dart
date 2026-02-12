import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'security.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SecureChatApp());
}

class SecureChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF2481CC),
        scaffoldBackgroundColor: const Color(0xFF0E1621),
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String userId = "user_1"; // معرفك
  final String peerId = "user_2"; // معرف الطرف الآخر
  Timer? _typingTimer;

  // دالة تحديث حالة الكتابة
  void _onTyping() {
    FirebaseFirestore.instance.collection('users').doc(userId).set({
      'isTyping': true,
    }, SetOptions(merge: true));

    // إيقاف الحالة بعد ثانيتين من التوقف عن الكتابة
    _typingTimer?.cancel();
    _typingTimer = Timer(Duration(seconds: 2), () {
      FirebaseFirestore.instance.collection('users').doc(userId).set({
        'isTyping': false,
      }, SetOptions(merge: true));
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    String encryptedText = SecureChat.encrypt(_messageController.text);
    _messageController.clear();
    await FirebaseFirestore.instance.collection('messages').add({
      'text': encryptedText,
      'createdAt': FieldValue.serverTimestamp(),
      'senderId': userId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF17212B),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("CardiaChat Pro"),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(peerId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Text("متصل", style: TextStyle(fontSize: 12));
                bool isTyping = snapshot.data?.get('isTyping') ?? false;
                bool isOnline = snapshot.data?.get('isOnline') ?? false;
                
                if (isTyping) return Text("جاري الكتابة...", style: TextStyle(fontSize: 12, color: Colors.greenAccent, fontWeight: FontWeight.bold));
                return Text(isOnline ? "متصل الآن" : "آخر ظهور قريب", style: TextStyle(fontSize: 12, color: Colors.grey));
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    String decrypted = "🔒 رسالة مشفرة";
                    try { decrypted = SecureChat.decrypt(doc['text']); } catch (e) {}
                    return Align(
                      alignment: doc['senderId'] == userId ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: doc['senderId'] == userId ? Color(0xFF2B5278) : Color(0xFF182533),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(decrypted),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Color(0xFF17212B),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.add, color: Colors.blue), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: (text) => _onTyping(), // استدعاء دالة الكتابة هنا
              decoration: InputDecoration(hintText: "اكتب رسالة...", border: InputBorder.none),
            ),
          ),
          IconButton(icon: Icon(Icons.send, color: Colors.blue), onPressed: _sendMessage),
        ],
      ),
    );
  }
}
