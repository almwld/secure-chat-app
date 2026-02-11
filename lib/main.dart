import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ملاحظة: تهيئة فايربيس بدون خيارات قد تفشل في بعض النسخ، لذا نستخدم try-catch
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase already initialized or error: $e");
  }
  runApp(SecureApp());
}

class SecureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0E1621)),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendSecureMessage() async {
    if (_controller.text.isNotEmpty) {
      final text = _controller.text;
      _controller.clear();
      
      try {
        String encrypted = SecureChat.encrypt(text);
        await FirebaseFirestore.instance.collection('messages').add({
          'text': encrypted,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Secure Chat"), backgroundColor: const Color(0xFF17212B)),
      body: Column(
        children: [
          Expanded(child: Center(child: Text("قاعدة البيانات متصلة الآن", style: TextStyle(color: Colors.grey)))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: "رسالة مشفرة...", border: OutlineInputBorder()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF5288C1)), 
                  onPressed: _sendSecureMessage, // تم تصحيح الاسم هنا
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
