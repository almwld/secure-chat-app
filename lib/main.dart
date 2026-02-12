import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:local_auth/local_auth.dart'; // استيراد مكتبة البصمة
import 'security.dart';
import 'chat_screen.dart'; // سنفصل شاشة الدردشة لاحقاً

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
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication(); // محرك البصمة
  final String masterCode = "adminz";

  // دالة التحقق من البصمة
  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'يرجى تأكيد هويتك لفتح نظام التشفير',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      print(e);
    }

    if (authenticated) {
      _navigateToChat();
    }
  }

  void _checkCode() {
    if (_passController.text == masterCode) {
      // إذا كان الكود صحيحاً، نطلب البصمة كخطوة تأكيد ثانية
      _authenticateWithBiometrics();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("الكود الرئيسي غير صحيح")));
    }
  }

  void _navigateToChat() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, size: 100, color: Colors.blueAccent),
              SizedBox(height: 40),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Master Access Code",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  filled: true,
                  fillColor: Color(0xFF17212B),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _checkCode,
                icon: Icon(Icons.fingerprint),
                label: Text("فتح النظام الآمن"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
