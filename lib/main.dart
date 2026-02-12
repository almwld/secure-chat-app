import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translator/translator.dart'; // مكتبة الترجمة
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
  final GoogleTranslator translator = GoogleTranslator();
  final TextEditingController _controller = TextEditingController();

  // دالة الترجمة الفورية
  void _translateMessage(String text) async {
    var translation = await translator.translate(text, to: 'ar'); // الترجمة للعربية تلقائياً
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF17212B),
        title: Text("الترجمة الفورية", style: TextStyle(fontSize: 16)),
        content: Text(translation.text),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("تم"))
        ],
      ),
    );
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
                    String dec = "";
                    try { dec = SecureChat.decrypt(doc['text']); } catch (e) { dec = "خطأ في فك التشفير"; }

                    return GestureDetector(
                      onLongPress: () => _translateMessage(dec), // ترجمة عند الضغط المطول
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Color(0xFF2B5278), borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dec),
                              SizedBox(height: 5),
                              Text("اضغط مطولاً للترجمة", style: TextStyle(fontSize: 8, color: Colors.white54)),
                            ],
                          ),
                        ),
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
          Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: "رسالة...", border: InputBorder.none))),
          IconButton(icon: Icon(Icons.send, color: Colors.blue), onPressed: () {
             if (_controller.text.isNotEmpty) {
               FirebaseFirestore.instance.collection('messages').add({
                 'text': SecureChat.encrypt(_controller.text),
                 'createdAt': FieldValue.serverTimestamp(),
               });
               _controller.clear();
             }
          }),
        ],
      ),
    );
  }
}
