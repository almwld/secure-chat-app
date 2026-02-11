import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SecureApp());
}

class SecureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Color(0xFF0E1621)),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  void _sendSecureMessage() {
    if (_controller.text.isNotEmpty) {
      // تشفير الرسالة قبل إرسالها للسحابة
      String encrypted = SecureChat.encrypt(_controller.text);
      FirebaseFirestore.instance.collection('messages').add({
        'text': encrypted,
        'createdAt': Timestamp.now(),
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Secure Chat"), backgroundColor: Color(0xFF17212B)),
      body: Column(
        children: [
          Expanded(child: Container()), // هنا ستعرض الرسائل لاحقاً
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "رسالة مشفرة...", border: OutlineInputBorder()),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPress: _sendSecureMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
