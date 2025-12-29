import 'package:flutter/material.dart';
import 'dart:async'; // Zamanlayıcı için
import 'dart:math';  // Rastgele sayı üretmek için
import '../../services/odev_service.dart';

class SansliOgrenciSayfasi extends StatefulWidget {
  final OdevService service;

  const SansliOgrenciSayfasi({super.key, required this.service});

  @override
  State<SansliOgrenciSayfasi> createState() => _SansliOgrenciSayfasiState();
}

class _SansliOgrenciSayfasiState extends State<SansliOgrenciSayfasi> {
  List<String> ogrenciler = [];
  String secilenIsim = "Hazır mısın?"; // Ekranda yazan metin
  bool isSearching = false; // Animasyon dönüyor mu?
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Veritabanından öğrencileri çekiyoruz
    ogrenciler = widget.service.ogrencileriGetir();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Sayfadan çıkarsa zamanlayıcıyı durdur
    super.dispose();
  }

  void _sansliKisiyiSec() {
    if (ogrenciler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Listede hiç öğrenci yok!")),
      );
      return;
    }

    setState(() {
      isSearching = true;
    });

    int turSayisi = 0;
    
    // 100 milisaniyede bir isim değişsin (Hızlı geçiş)
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        // Rastgele bir isim seç ve ekrana yaz
        int randomIndex = Random().nextInt(ogrenciler.length);
        
        // Eğer isim "Ali (6-A)" formatındaysa sadece "Ali" kısmını alalım
        String hamIsim = ogrenciler[randomIndex];
        if (hamIsim.contains("(")) {
          secilenIsim = hamIsim.split("(")[0].trim();
        } else {
          secilenIsim = hamIsim;
        }
      });

      turSayisi++;

      // Yaklaşık 3 saniye (30 tur) sonra durdur
      if (turSayisi >= 30) {
        timer.cancel();
        setState(() {
          isSearching = false;
        });
        _kazananiKutla();
      }
    });
  }

  void _kazananiKutla() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Center(child: Text("🎉 Şanslı Kişi 🎉")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 60, color: Colors.orange),
              const SizedBox(height: 10),
              Text(
                secilenIsim,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                child: const Text("Tamam"),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        title: const Text("Şanslı Öğrenci"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Bugünün şanslısı kim?",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 30),
            
            // --- İSİM KARTI ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    isSearching ? Icons.hourglass_top : Icons.person,
                    size: 50,
                    color: isSearching ? Colors.orange : Colors.indigo,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    secilenIsim,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 50),

            // --- BUTON ---
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                onPressed: isSearching ? null : _sansliKisiyiSec, // Dönüyorsa tıklanmasın
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 10,
                ),
                child: Text(
                  isSearching ? "Seçiliyor..." : "Çarkı Çevir 🎲",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}