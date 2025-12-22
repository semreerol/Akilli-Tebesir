import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/teacher.dart';
import '../odev_service.dart';
import 'register_page.dart'; 
import 'ana_sayfa.dart'; // <-- 1. BU IMPORT'U EKLEDİK (Sayfaya gitmesi için)

class LoginPage extends StatefulWidget {
  final OdevService service;

  const LoginPage({super.key, required this.service});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final box = Hive.box<Teacher>('teachersBox');

    try {
      // Kullanıcıyı veritabanında arıyoruz
      final teacher = box.values.firstWhere(
        (t) => t.username == username && t.password == password,
      );

      // --- GİRİŞ BAŞARILI ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hoşgeldiniz ${teacher.name}")),
      );

      // 2. ANA SAYFAYA YÖNLENDİRME (Artık açık ve çalışır durumda)
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => AnaSayfa(service: widget.service)),
      );
      
    } catch (e) {
      // --- KULLANICI BULUNAMADI ---
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kullanıcı adı veya şifre hatalı!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Öğretmen Girişi")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Kullanıcı Adı",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Şifre",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: const Text("Giriş Yap", style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text("Hesabın yok mu? Kayıt Ol"),
            )
          ],
        ),
      ),
    );
  }
}