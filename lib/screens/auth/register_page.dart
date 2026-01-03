import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/odev_service.dart';
import '../home/ana_sayfa.dart';

class RegisterPage extends StatefulWidget {
  final OdevService service; // <-- İşte eksik olan kısım buydu

  const RegisterPage({super.key, required this.service});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final AuthService _authService = AuthService(); // Firebase Auth servisi

  void _kayitOl() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları doldurun.")));
      return;
    }

    try {
      // 1. Firebase'e Kayıt Ol
      final user = await _authService.signUp(_emailController.text, _passwordController.text);
      
      if (user != null) {
        // (İsteğe bağlı) Kullanıcı adını güncellemek için:
        // await user.updateDisplayName(_nameController.text);

        if (!mounted) return;
        
        // 2. Başarılıysa Ana Sayfaya Git
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => AnaSayfa(
              service: widget.service, // Servisi aktarıyoruz
              teacherName: _nameController.text, // Girilen ismi ana sayfaya taşıyoruz
            ),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kayıt Hatası: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        title: const Text("Yeni Hesap Oluştur"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Öğretmen Kaydı", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Ad Soyad", prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "E-Posta", prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Şifre", prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _kayitOl,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                      child: const Text("Kayıt Ol", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}