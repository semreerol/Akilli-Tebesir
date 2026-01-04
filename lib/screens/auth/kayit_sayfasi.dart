import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/odev_service.dart';

class KayitSayfasi extends StatefulWidget {
  final OdevService service;
  const KayitSayfasi({super.key, required this.service});

  @override
  State<KayitSayfasi> createState() => _KayitSayfasiState();
}

class _KayitSayfasiState extends State<KayitSayfasi> {
  // Yeni Controller: İsim için
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _kayitOl() async {
    // 1. Boş Alan Kontrolü
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm alanları doldurun."),
          backgroundColor: Colors.redAccent,
        )
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Kayıt işlemini yap
    var user = await _authService.signUp(
      _emailController.text.trim(), 
      _passwordController.text.trim(),
      _nameController.text.trim()
    );

    if (user != null) {
      // 3. Doğrulama mailini gönder
      await _authService.dogrulamaMailiGonder();
      
      // 🔥 YENİ EKLENEN KISIM: ZORLA ÇIKIŞ YAP 🔥
      // Bu satır olmazsa main.dart seni otomatik ana sayfaya atar!
      await _authService.signOut(); 
      
      if (!mounted) return;
      
      // 4. Bilgi penceresini göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.mark_email_unread, color: Colors.orange), // İkonu değiştirdim
              SizedBox(width: 10),
              Text("Son Bir Adım"),
            ],
          ),
          content: Text(
            "Harika! Kaydınız oluşturuldu, ${_nameController.text} Öğretmenim.\n\n"
            "Ancak güvenliğiniz için e-posta adresinize (${_emailController.text}) bir onay linki gönderdik.\n\n"
            "Lütfen o linke tıkladıktan sonra giriş yapınız."
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context); // Dialogu kapat
                Navigator.pop(context); // Kayıt sayfasını kapat (Giriş'e dön)
              },
              child: const Text("Tamam, Giriş Ekranına Dön"),
            )
          ],
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kayıt başarısız! E-posta hatalı veya kullanımda."),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Hesap Oluştur")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 80, color: Colors.indigo),
              const SizedBox(height: 20),
              
              // --- AD SOYAD ALANI ---
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words, // Baş harfleri büyük yap
                decoration: const InputDecoration(
                  labelText: "Ad Soyad",
                  prefixIcon: Icon(Icons.badge), // Yaka kartı ikonu
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "E-posta",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Şifre",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _kayitOl,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Kayıt Ol", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}