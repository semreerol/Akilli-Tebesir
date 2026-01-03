import 'package:flutter/material.dart';
import '../../services/odev_service.dart';
import '../../services/auth_service.dart'; // AuthService'i çağırıyoruz
import '../auth/giris_sayfasi.dart';

class ProfilSayfasi extends StatelessWidget {
  final OdevService service;
  final String teacherName;

  const ProfilSayfasi({
    super.key, 
    required this.service, 
    required this.teacherName
  });

  void _cikisYap(BuildContext context) async {
    // Firebase oturumunu kapat
    await AuthService().signOut();

    if (!context.mounted) return;

    // Giriş sayfasına geri gönder (Geri gelinemez şekilde)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(service: service)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              teacherName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Öğretmen Hesabı",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),
            
            // Çıkış Butonu
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _cikisYap(context),
                icon: const Icon(Icons.logout),
                label: const Text("Çıkış Yap"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}