import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipe_to/swipe_to.dart'; // مكتبة السحب
import 'security.dart';

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
  String? replyingTo; // لتخزين الرسالة التي يتم الرد عليها

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    String textToSend = _controller.text;
    if (replyingTo != null) {
      textToSend = "الرد على ($replyingTo): " + textToSend;
    }
    
    String encrypted = SecureChat.encrypt(textToSend);
    _controller.clear();
    setState(() => replyingTo = null); // إخفاء شريط الرد بعد الإرسال

    await FirebaseFirestore.instance.collection('messages').add({
      'text': encrypted,
      'createdAt': FieldValue.serverTimestamp(),
      'senderId': 'user_1',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CardiaChat Pro"), backgroundColor: Color(0xFF17212B)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    String dec = "🔒 مشفر";
                    try { dec = SecureChat.decrypt(doc['text']); } catch (e) {}

                    return SwipeTo(
                      onRightSwipe: () {
                        setState(() => replyingTo = dec); // تفعيل الرد عند السحب
                      },
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Color(0xFF2B5278), borderRadius: BorderRadius.circular(15)),
                          child: Text(dec),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (replyingTo != null) _buildReplyPreview(), // شريط معاينة الرد
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.black26,
      child: Row(
        children: [
          Icon(Icons.reply, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(child: Text(replyingTo!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey))),
          IconButton(icon: Icon(Icons.close), onPressed: () => setState(() => replyingTo = null)),
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
          Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: "اسحب أي رسالة للرد عليها...", border: InputBorder.none))),
          IconButton(icon: Icon(Icons.send, color: Colors.blue), onPressed: _sendMessage),
        ],
      ),
    );
  }
}
