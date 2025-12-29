import 'package:flutter/material.dart';
import 'package:odev_takip/screens/profil_sayfasi.dart';
import 'package:odev_takip/services/odev_service.dart';
import 'package:odev_takip/services/odev_service.dart';
// Dosya yollarını klasör yapına göre kontrol et (screens/students vb.)
import '../students/ogrenci_sayfalari.dart';
import '../homeworks/odev_sayfalari.dart';
import '../home/ders_programi_sayfasi.dart';
import '../home/sansli_ogrenci_sayfasi.dart';
import 'package:odev_takip/screens/profil_sayfasi.dart'; // <-- PROFİL SAYFASI IMPORT'U (Yolunu kontrol et)
import '../../widgets/istatistik_karti.dart'; // <-- WIDGET IMPORT'U

class AnaSayfa extends StatefulWidget {
  final OdevService service;
  final String teacherName; 

  const AnaSayfa({
    super.key,
    required this.service,
    required this.teacherName, 
  });

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int ogrenciSayisi = 0;
  int odevSayisi = 0;

  @override
  void initState() {
    super.initState();
    _verileriGuncelle();
  }

  void _verileriGuncelle() {
    setState(() {
      ogrenciSayisi = widget.service.ogrencileriGetir().length;
      odevSayisi = widget.service.odevleriGetir().length;
    });
  }

  @override
  Widget build(BuildContext context) {
    _verileriGuncelle(); 

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Öğretmen Paneli", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // --- GÜNCELLEME: ÇIKIŞ YERİNE PROFİL BUTONU ---
          IconButton(
            icon: const Icon(Icons.person), // İkon değişti
            tooltip: 'Profil Ayarları',
            onPressed: () {
              // Profil sayfasına gidiyoruz
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilSayfasi(
                    service: widget.service,
                    teacherName: widget.teacherName, // İsmi buraya aktarıyoruz
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Text(
                "Hoş Geldiniz, ${widget.teacherName}", 
                style: const TextStyle(
                  fontSize: 18, 
                  color: Colors.grey, 
                  fontWeight: FontWeight.w500
                ),
              ),

              const SizedBox(height: 5), 
              
              const Text(
                "Özet Bilgiler",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 20),

              // --- KARTLAR (ARTIK WIDGET KULLANIYORUZ) ---
              Row(
                children: [
                  // _buildStatCard YERİNE IstatistikKarti YAZDIK
                  IstatistikKarti(
                    title: "Öğrenciler",
                    count: ogrenciSayisi.toString(),
                    color: Colors.orange,
                    icon: Icons.people,
                    onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => OgrenciSayfalari(service: widget.service))).then((_) => _verileriGuncelle());
                    },
                  ),
                  const SizedBox(width: 16),
                  IstatistikKarti(
                    title: "Ödevler",
                    count: odevSayisi.toString(),
                    color: Colors.purple,
                    icon: Icons.book,
                     onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => OdevSayfalari(service: widget.service))).then((_) => _verileriGuncelle());
                    },
                  ),
                ],
              ),
              // ---------------------------------------------
              
              const SizedBox(height: 30),
              const Text("Hızlı İşlemler", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // --- DERS PROGRAMI KARTI ---
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.calendar_month, color: Colors.green), 
                  ),
                  title: const Text("Ders Programı"),
                  subtitle: const Text("Haftalık planını düzenle"), 
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DersProgramiSayfasi(service: widget.service),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10), 

              // --- ŞANSLI ÖĞRENCİ KARTI ---
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.casino, color: Colors.orange), 
                  ),
                  title: const Text("Şanslı Öğrenci"),
                  subtitle: const Text("Rastgele bir öğrenci seç"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SansliOgrenciSayfasi(service: widget.service),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // DİKKAT: Buradaki eski _buildStatCard fonksiyonunu sildik.
  // Artık yukarıda import ettiğimiz 'IstatistikKarti' çalışıyor.
}