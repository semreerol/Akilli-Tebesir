import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../services/odev_service.dart';

class SansliOgrenciSayfasi extends StatefulWidget {
  final OdevService service;

  const SansliOgrenciSayfasi({super.key, required this.service});

  @override
  State<SansliOgrenciSayfasi> createState() => _SansliOgrenciSayfasiState();
}

class _SansliOgrenciSayfasiState extends State<SansliOgrenciSayfasi> {
  List<String> siniflar = [];
  String? secilenSinif;
  
  String ekrandakiIsim = "Sınıf Seçiniz"; 
  bool isSearching = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _siniflariYukle();
  }

  // Sınıfları veritabanından çek
  Future<void> _siniflariYukle() async {
    var gelenler = await widget.service.siniflariGetir();
    setState(() {
      siniflar = gelenler;
      if (siniflar.isNotEmpty) {
        secilenSinif = siniflar.first;
        ekrandakiIsim = "Hazır mısın $secilenSinif?";
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _sansliKisiyiSec() async {
    if (secilenSinif == null) return;

    // Veritabanından öğrencileri çek (BEKLEME NOKTASI)
    List<String> sinifListesi = await widget.service.ogrencileriSinifaGoreGetir(secilenSinif!);

    if (sinifListesi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$secilenSinif sınıfında hiç öğrenci yok!")),
      );
      return;
    }

    setState(() {
      isSearching = true;
    });

    int turSayisi = 0;
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        int randomIndex = Random().nextInt(sinifListesi.length);
        String hamIsim = sinifListesi[randomIndex];
        // İsmi temizle: "Ahmet (6-A)" -> "Ahmet"
        ekrandakiIsim = hamIsim.split("(")[0].trim();
      });

      turSayisi++;

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
                ekrandakiIsim,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              Text("($secilenSinif)", style: const TextStyle(color: Colors.grey)),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
            // Sınıf Seçimi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: secilenSinif,
                  dropdownColor: Colors.indigo[700],
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  hint: const Text("Sınıf Seç", style: TextStyle(color: Colors.white70)),
                  items: siniflar.map((String sinif) {
                    return DropdownMenuItem<String>(
                      value: sinif,
                      child: Text("$sinif Sınıfı"),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      secilenSinif = newValue;
                      ekrandakiIsim = "Hazır mısın $newValue?";
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // İsim Kartı
            Container(
              width: 300, // Sabit genişlik
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
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
                    ekrandakiIsim,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 50),

            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                onPressed: (isSearching || secilenSinif == null) ? null : _sansliKisiyiSec,
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