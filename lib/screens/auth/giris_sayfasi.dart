import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/teacher.dart';
import '../../services/odev_service.dart';
import 'register_page.dart';
import '../home/ana_sayfa.dart';

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

    // Veritabanı kutusunu çağırıyoruz
    final box = Hive.box<Teacher>('teachersBox');

    try {
      // 1. Kullanıcı adı ve şifresi eşleşen öğretmeni bul
      final teacher = box.values.firstWhere(
        (t) => t.username == username && t.password == password,
      );

      // --- GİRİŞ BAŞARILI ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Giriş Başarılı! Hoşgeldiniz ${teacher.name}")),
      );

      // 2. ANA SAYFAYA YÖNLENDİRME
      // ÖNEMLİ: Burada 'teacherName' parametresini gönderiyoruz.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AnaSayfa(
            service: widget.service,
            teacherName: teacher.name, // <-- BURASI EKLENDİ
          ),
        ),
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
        child: SingleChildScrollView( // Klavye açılınca taşma olmasın diye
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 80, color: Colors.indigo),
              const SizedBox(height: 20),
              
              // Kullanıcı Adı
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Kullanıcı Adı",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              
              // Şifre
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
              
              // Giriş Butonu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Giriş Yap", style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 10),
              
              // Kayıt Ol Linki
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
      ),
    );
  }
}