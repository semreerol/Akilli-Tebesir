import 'package:flutter/material.dart';
import '../odev_service.dart';
import 'ogrenci_sayfalari.dart';
import 'odev_sayfalari.dart';

class AnaSayfa extends StatefulWidget {
  final OdevService service;

  const AnaSayfa({super.key, required this.service});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  // Sayıların güncel görünmesi için state kullanıyoruz
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
    // Sayfaya her geri dönüldüğünde verileri yenilemek için
    _verileriGuncelle();

    return Scaffold(
      backgroundColor: Colors.grey[100], // Arka planı hafif gri yapalım
      appBar: AppBar(
        title: const Text("Öğretmen Paneli", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hoş Geldiniz,",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const Text(
              "Özet Bilgiler", // Buraya giriş yapan öğretmenin adı da gelebilir
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 20),

            // --- İSTATİSTİK KARTLARI ---
            Row(
              children: [
                _buildStatCard(
                  title: "Öğrenciler",
                  count: ogrenciSayisi.toString(),
                  color: Colors.orange,
                  icon: Icons.people,
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => OgrenciSayfalari(service: widget.service))).then((_) => _verileriGuncelle());
                  },
                ),
                const SizedBox(width: 16),
                _buildStatCard(
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
            
            const SizedBox(height: 30),
            const Text("Hızlı İşlemler", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // --- BÜYÜK MENÜ KARTI ---
            Card(
              color: Colors.white,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.add_task, color: Colors.green),
                ),
                title: const Text("Yeni Ders Programı Ekle"),
                subtitle: const Text("Yakında eklenecek..."),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tekrar eden kart tasarımı için özel Widget fonksiyonu
  Widget _buildStatCard({required String title, required String count, required Color color, required IconData icon, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(count, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}