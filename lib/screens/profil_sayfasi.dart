import 'package:flutter/material.dart';
import 'package:odev_takip/screens/auth/giris_sayfasi.dart';
import '../../services/odev_service.dart'; // Klasör yapına göre ../../ olabilir
import 'auth/giris_sayfasi.dart';       // Auth klasörüne taşıdığımız için

class ProfilSayfasi extends StatelessWidget {
  final String teacherName; // <-- İsim bilgisini buraya alıyoruz
  final OdevService service;

  const ProfilSayfasi({
    super.key,
    required this.teacherName, // <-- Zorunlu kıldık
    required this.service,
  });

  // Çıkış Yapmadan Önce Onay Kutusu
  void _cikisYap(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text("Hesabınızdan çıkış yapmak istiyor musunuz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // İptal
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () {
              // Giriş sayfasına yönlendir ve geçmişi temizle
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage(service: service)),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, 
              foregroundColor: Colors.white
            ),
            child: const Text("Çıkış Yap"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Hafif gri arka plan
      appBar: AppBar(
        title: const Text("Profil Ayarları"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          // --- 1. PROFİL FOTOĞRAFI VE İSİM ---
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(
                    teacherName.isNotEmpty ? teacherName[0].toUpperCase() : "Ö",
                    style: const TextStyle(fontSize: 40, color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  teacherName, // Gerçek isim burada yazacak
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const Text(
                  "Öğretmen Hesabı", 
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),

          // --- 2. AYARLAR MENÜSÜ ---
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text("Hesap Ayarları", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.indigo),
                  title: const Text("İsim Güncelle"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Bu özellik yakında eklenecek!")),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.indigo),
                  title: const Text("Şifre Değiştir"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Bu özellik yakında eklenecek!")),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- 3. ÇIKIŞ BUTONU ---
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Çıkış Yap", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () => _cikisYap(context), // Fonksiyonu çağırıyoruz
            ),
          ),
          
          const SizedBox(height: 20),
          const Center(
             child: Text("Versiyon 1.0.0", style: TextStyle(color: Colors.grey))
          ),
        ],
      ),
    );
  }
}