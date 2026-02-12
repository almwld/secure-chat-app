import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

  // ميزة التقاط صور/فيديو
  void _pickMedia(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo != null) {
      // هنا يتم تشفير ملف الصورة ورفعه لـ Firebase Storage
      print("تم اختيار وسائط: ${photo.path}");
    }
  }

  // ميزة رفع الملفات (PDF, Word)
  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
       print("تم اختيار ملف: ${result.files.first.name}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF17212B),
        title: Text("CardiaChat Pro"),
        actions: [
          IconButton(icon: Icon(Icons.videocam), onPressed: () {}), // اتصال فيديو
          IconButton(icon: Icon(Icons.call), onPressed: () {}),     // اتصال صوتي
        ],
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: Text("مساحة الدردشة المشفرة", style: TextStyle(color: Colors.grey)))),
          _buildAdvancedInput(),
        ],
      ),
    );
  }

  Widget _buildAdvancedInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      color: Color(0xFF17212B),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: Icon(Icons.add_circle_outline, color: Colors.blue), onPressed: _showAttachmentMenu),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "رسالة...",
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey), // للملصقات
                  ),
                ),
              ),
              IconButton(icon: Icon(Icons.camera_alt_outlined, color: Colors.grey), onPressed: () => _pickMedia(ImageSource.camera)),
              GestureDetector(
                onLongPress: () => print("بدء تسجيل صوتي..."), // تسجيل صوتي
                child: Icon(Icons.mic, color: Colors.blue, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF17212B),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _actionItem(Icons.insert_drive_file, "ملف", Colors.purple, _pickFiles),
            _actionItem(Icons.camera_alt, "كاميرا", Colors.red, () => _pickMedia(ImageSource.camera)),
            _actionItem(Icons.image, "معرض", Colors.pink, () => _pickMedia(ImageSource.gallery)),
            _actionItem(Icons.headphones, "صوت", Colors.orange, () {}),
            _actionItem(Icons.location_on, "الموقع", Colors.green, () {}),
            _actionItem(Icons.person, "جهة اتصال", Colors.blue, () {}),
          ],
        ),
      ),
    );
  }

  Widget _actionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        CircleAvatar(radius: 30, backgroundColor: color, child: IconButton(icon: Icon(icon, color: Colors.white), onPressed: onTap)),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
