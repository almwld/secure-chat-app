import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glass_kit/glass_kit.dart'; // مكتبة التصميم الزجاجي
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
      theme: ThemeData.dark(),
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

  // واجهة فقاعة الرسالة الزجاجية
  Widget _buildGlassBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GlassContainer.frostedGlass(
        height: 60,
        width: 250,
        margin: EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(20),
        child: Center(child: Text(text, style: TextStyle(color: Colors.white))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("CardiaChat Glass Pro"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.phone_in_talk_outlined, color: Colors.blueAccent),
            onPressed: () => _startVoiceCall(), // ميزة المكالمات
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
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
                      String dec = "🔒";
                      try { dec = SecureChat.decrypt(doc['text']); } catch (e) {}
                      return _buildGlassBubble(dec, true);
                    },
                  );
                },
              ),
            ),
            _buildGlassInput(),
          ],
        ),
      ),
    );
  }

  // حقل إدخال زجاجي
  Widget _buildGlassInput() {
    return GlassContainer.frostedGlass(
      height: 70,
      width: double.infinity,
      margin: EdgeInsets.all(15),
      borderRadius: BorderRadius.circular(30),
      child: Row(
        children: [
          SizedBox(width: 20),
          Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: "رسالة زجاجية...", border: InputBorder.none))),
          IconButton(icon: Icon(Icons.send, color: Colors.blueAccent), onPressed: () {
            FirebaseFirestore.instance.collection('messages').add({
              'text': SecureChat.encrypt(_controller.text),
              'createdAt': FieldValue.serverTimestamp(),
            });
            _controller.clear();
          }),
        ],
      ),
    );
  }

  void _startVoiceCall() {
    // منطق بدء مكالمة Agora (سنتوسع فيه في التحديث القادم)
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("جاري الاتصال المشفر...")));
  }
}
