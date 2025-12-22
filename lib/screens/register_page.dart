import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/teacher.dart'; // Model dosyanızın yolu

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 1. Verileri almak için kontrolcüler (Kumandalar)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Kayıt İşlemi Fonksiyonu
  void _register() {
    final String name = _nameController.text.trim();
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    // Boş alan kontrolü
    if (name.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm alanları doldurunuz!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Hive Kutusunu Çağır (main.dart'ta açtığımız kutu)
    final box = Hive.box<Teacher>('teachersBox');

    // Kullanıcı adı daha önce alınmış mı kontrolü (İsteğe bağlı ekstra güvenlik)
    bool userExists = box.values.any((teacher) => teacher.username == username);
    if (userExists) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bu kullanıcı adı zaten kullanılıyor.")),
      );
      return;
    }

    // 3. Yeni Öğretmen Nesnesini Oluştur
    final newTeacher = Teacher(
      name: name,
      username: username,
      password: password,
    );

    // 4. Kutuya Ekle (Veritabanına Kayıt)
    box.add(newTeacher);

    // 5. Başarılı Mesajı ve Geri Dönüş
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Kayıt Başarılı! Hoşgeldin $name öğretmenim.")),
    );

    Navigator.pop(context); // Giriş sayfasına geri gönder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Öğretmen Kaydı"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.app_registration, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              
              // --- İSİM ALANI ---
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Ad Soyad (Örn: Yasemin Öğretmen)",
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // --- KULLANICI ADI ALANI ---
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Kullanıcı Adı",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // --- ŞİFRE ALANI ---
              TextField(
                controller: _passwordController,
                obscureText: true, // Şifreyi gizle
                decoration: const InputDecoration(
                  labelText: "Şifre",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // --- KAYIT BUTONU ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Kayıt Ol",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}