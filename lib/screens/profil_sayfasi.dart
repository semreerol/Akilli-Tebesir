import 'package:flutter/material.dart';
import '../odev_service.dart';
import 'giris_sayfasi.dart';

class ProfilSayfasi extends StatelessWidget {
  final OdevService service;
  const ProfilSayfasi({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profil")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.indigo),
            SizedBox(height: 20),
            Text("Öğretmen Hesabı", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100, foregroundColor: Colors.red),
              icon: Icon(Icons.logout),
              label: Text("Çıkış Yap"),
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginPage(service: service)), (route) => false);
              },
            )
          ],
        ),
      ),
    );
  }
}