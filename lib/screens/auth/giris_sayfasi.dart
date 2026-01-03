import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/odev_service.dart';
import '../home/ana_sayfa.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  // Artık OdevService yerine AuthService kullanacağız ama
  // geçiş aşamasında OdevService'i de parametre olarak tutabiliriz.
  final OdevService service; 

  const LoginPage({super.key, required this.service});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Servisi çağırıyoruz

  // --- ŞİFRE SIFIRLAMA ---
  void _sifremiUnuttum() {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen önce mail adresinizi yazın.")));
      return;
    }
    
    _authService.resetPassword(_emailController.text).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sıfırlama bağlantısı mailinize gönderildi!")));
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: ${e.toString()}")));
    });
  }

  // --- GOOGLE İLE GİRİŞ ---
  void _googleIleGiris() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
         if(!mounted) return;
         Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AnaSayfa(
              service: widget.service, 
              teacherName: user.displayName ?? "Google Kullanıcısı", // Google'dan gelen isim
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Giriş Hatası: $e")));
    }
  }

  // --- NORMAL GİRİŞ ---
  void _girisYap() async {
    try {
      final user = await _authService.signIn(_emailController.text, _passwordController.text);
      if (user != null) {
        if(!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AnaSayfa(
              service: widget.service, 
              teacherName: user.email!.split('@')[0], // Mailin başını isim yapalım şimdilik
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Giriş başarısız. Bilgileri kontrol edin.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school, size: 80, color: Colors.indigo),
                  const SizedBox(height: 10),
                  const Text("Akıllı Tebeşir", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const SizedBox(height: 30),
                  
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
                  
                  // ŞİFREMİ UNUTTUM
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _sifremiUnuttum,
                      child: const Text("Şifremi Unuttum"),
                    ),
                  ),

                  const SizedBox(height: 10),
                  
                  // GİRİŞ BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _girisYap,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                      child: const Text("Giriş Yap", style: TextStyle(fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 15),
                  const Text("veya", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 15),

                  // GOOGLE BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _googleIleGiris,
                      icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.indigo), // Google'ı andıran bir ikon
                      // İkon yoksa Icon(Icons.g_mobiledata) kullanabilirsin
                      label: const Text("Google ile Giriş Yap"),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Hesabın yok mu?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage(service: widget.service)));
                        },
                        child: const Text("Kayıt Ol"),
                      ),
                    ],
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