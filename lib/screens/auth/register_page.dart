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
  // Kontrolcüler
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

    // 2. Yükleniyor durumunu aç
    setState(() => _isLoading = true);

    // 3. Servis üzerinden kayıt ol (İsim parametresiyle birlikte)
    var user = await _authService.signUp(
      _emailController.text.trim(), 
      _passwordController.text.trim(),
      _nameController.text.trim() // İsim burada gönderiliyor
    );

    if (user != null) {
      // 4. Doğrulama mailini tetikle
      await _authService.dogrulamaMailiGonder();
      
      if (!mounted) return;
      
      // 5. Başarılı Dialog Kutusu
      showDialog(
        context: context,
        barrierDismissible: false, // Kullanıcı boşluğa basıp kapatamasın
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text("Kayıt Başarılı!"),
            ],
          ),
          content: Text(
            "Hoş geldin ${_nameController.text} Öğretmenim!\n\n"
            "Güvenliğiniz için e-posta adresinize (${_emailController.text}) bir doğrulama linki gönderdik.\n\n"
            "Lütfen mailinizi onaylayıp giriş yapınız."
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context); // Dialogu kapat
                Navigator.pop(context); // Giriş sayfasına geri dön
              },
              child: const Text("Tamam, Giriş Yap"),
            )
          ],
        ),
      );
    } else {
      // Hata Durumu
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kayıt başarısız! E-posta hatalı veya zaten kullanımda olabilir."),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo, // Arka plan rengi
      appBar: AppBar(
        title: const Text("Yeni Hesap Oluştur"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add_alt_1, size: 70, color: Colors.indigo),
                  const SizedBox(height: 20),
                  const Text(
                    "Ailemize Katılın",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  
                  // --- AD SOYAD ALANI ---
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words, // Baş harfleri otomatik büyüt
                    decoration: const InputDecoration(
                      labelText: "Ad Soyad",
                      hintText: "Örn: Ahmet Yılmaz",
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- E-POSTA ALANI ---
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "E-posta",
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // --- ŞİFRE ALANI ---
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Şifre",
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // --- KAYIT BUTONU ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _kayitOl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 5,
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            height: 24, 
                            width: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text("Kayıt Ol", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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