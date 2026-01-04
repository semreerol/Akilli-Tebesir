import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/odev_service.dart';
import '../home/ana_sayfa.dart';
import 'kayit_sayfasi.dart'; // Yeni oluşturduğumuz sayfayı çağırıyoruz

class LoginPage extends StatefulWidget {
  final OdevService service;
  const LoginPage({super.key, required this.service});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _beniHatirla = false;

  @override
  void initState() {
    super.initState();
    _bilgileriYukle();
  }

  void _bilgileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _beniHatirla = prefs.getBool('beni_hatirla') ?? false;
      if (_beniHatirla) {
        _emailController.text = prefs.getString('kayitli_email') ?? '';
      }
    });
  }

  void _bilgileriKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    if (_beniHatirla) {
      await prefs.setBool('beni_hatirla', true);
      await prefs.setString('kayitli_email', _emailController.text);
    } else {
      await prefs.remove('beni_hatirla');
      await prefs.remove('kayitli_email');
    }
  }

  void _girisYap() async {
    setState(() => _isLoading = true);
    
    // 1. Giriş yapmayı dene
    var user = await _authService.signInWithEmail(_emailController.text, _passwordController.text);

    if (user != null) {
      // 2. KRİTİK ADIM: Sunucudan en güncel durumu çek!
      await user.reload(); 
      // Kullanıcı nesnesini yenilememiz gerekebilir, o yüzden tekrar alıyoruz:
      user = _authService.currentUser;

      // 3. E-posta doğrulanmış mı kontrol et
      if (user != null && !user.emailVerified) {
        if (!mounted) return;
        
        // Güvenlik: Hemen çıkış yap, içeri sokma
        await _authService.signOut();
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("E-posta Doğrulanmadı ⚠️"),
            content: const Text(
              "Giriş yapabilmek için mailinize gelen linke tıklamalısınız.\n\n"
              "Eğer maili göremiyorsanız Spam/Gereksiz kutusunu kontrol edin."
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text("Tamam")
              ),
            ],
          ),
        );
        
        setState(() => _isLoading = false);
        return; // Fonksiyondan çık, aşağıya inme!
      }
      
      // --- DOĞRULANMIŞSA İÇERİ AL ---
      _bilgileriKaydet();
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // İsim bilgisini user.displayName'den alıyoruz
          builder: (context) => AnaSayfa(
            service: widget.service, 
            teacherName: user?.displayName ?? "Öğretmenim"
          ),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Giriş başarısız! Bilgileri kontrol edin.")));
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  void _googleIleGiris() async {
    setState(() => _isLoading = true);
    var user = await _authService.signInWithGoogle();
    
    if (user != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AnaSayfa(service: widget.service, teacherName: user.displayName ?? "Öğretmenim"),
        ),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // --- ŞİFRE SIFIRLAMA PENCERESİ ---
  void _sifremiUnuttumDialog() {
    TextEditingController resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Şifremi Unuttum"),
          content: TextField(
            controller: resetEmailController,
            decoration: const InputDecoration(hintText: "E-posta adresinizi girin"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
            ElevatedButton(
              onPressed: () async {
                if (resetEmailController.text.isNotEmpty) {
                  await _authService.sifreSifirlamaMailiGonder(resetEmailController.text.trim());
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sıfırlama bağlantısı e-postanıza gönderildi! 📧")),
                  );
                }
              },
              child: const Text("Gönder"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school, size: 80, color: Colors.indigo),
                  const SizedBox(height: 10),
                  const Text("Akıllı Tebeşir", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const Text("Öğretmen Girişi", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 30),
                  
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "E-posta", prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Şifre", prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
                  ),

                  // --- ŞİFREMİ UNUTTUM & BENİ HATIRLA ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _beniHatirla,
                            activeColor: Colors.indigo,
                            onChanged: (val) => setState(() => _beniHatirla = val ?? false),
                          ),
                          const Text("Beni Hatırla", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      TextButton(
                        onPressed: _sifremiUnuttumDialog,
                        child: const Text("Şifremi Unuttum?", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _girisYap,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Giriş Yap"),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // --- KAYIT OL BUTONU ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Hesabınız yok mu?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => KayitSayfasi(service: widget.service)),
                          );
                        },
                        child: const Text("Kayıt Ol", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),

                  const Divider(),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _googleIleGiris,
                    icon: Image.asset('assets/google_logo.png', height: 24, errorBuilder: (c,o,s) => const Icon(Icons.login)), 
                    label: const Text("Google ile Giriş Yap"),
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