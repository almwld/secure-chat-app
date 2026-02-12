import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'dart:ui';

class CallScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية مشوشة (Blurred Background)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://via.placeholder.com/500"), // صورة المتصل
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // قسم هوية المتصل مع تأثير النبض
              Column(
                children: [
                  AvatarGlow(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage("https://via.placeholder.com/150"),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("جارٍ الاتصال المشفر...", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  Text("المستخدم المجهول", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
              
              // أزرار التحكم في الاتصال (زجاجية)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _callActionBtn(Icons.mic_off, Colors.white24),
                  _callActionBtn(Icons.videocam_off, Colors.white24),
                  _callActionBtn(Icons.volume_up, Colors.white24),
                ],
              ),
              
              // زر إنهاء المكالمة
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 20)]),
                  child: Icon(Icons.call_end, size: 40, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _callActionBtn(IconData icon, Color color) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: color,
      child: Icon(icon, color: Colors.white),
    );
  }
}
