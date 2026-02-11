#!/bin/bash

# 1. تحديث ملف الواجهة بكود احترافي
cat << 'EOT' > lib/main.dart
import 'package:flutter/material.dart';

void main() => runApp(ChatApp());

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Secure Chat UI')),
      body: Column(
        children: [
          Expanded(child: Center(child: Text("مرحباً بك في تطبيق الدردشة الآمنة"))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(decoration: InputDecoration(hintText: "اكتب رسالتك..."))),
                IconButton(icon: Icon(Icons.send), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
EOT

# 2. إضافة التغييرات والرفع تلقائياً
git add .
git commit -m "Auto-update: Professional Chat UI"
git push origin main

echo "------------------------------------------------"
echo "✅ تم تحديث الكود ورفعه بنجاح!"
echo "🚀 Codemagic سيبدأ بناء الـ APK الآن تلقائياً."
echo "------------------------------------------------"
