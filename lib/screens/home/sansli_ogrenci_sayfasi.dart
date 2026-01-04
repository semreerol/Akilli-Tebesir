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
  // Veri Listeleri
  List<String> siniflar = [];
  String? secilenSinif;
  
  // Kura Mantığı İçin Listeler
  List<String> tumSinifListesi = []; // Sınıfın tamamı (Yedek)
  List<String> kalanOgrenciler = []; // Henüz seçilmeyenler (Havuz)

  // Ekran Durumu
  String ekrandakiIsim = "Sınıf Seçiniz"; 
  bool isSearching = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _siniflariYukle();
  }

  Future<void> _siniflariYukle() async {
    var gelenler = await widget.service.siniflariGetir();
    setState(() {
      siniflar = gelenler;
      if (siniflar.isNotEmpty) {
        secilenSinif = siniflar.first;
        _ogrencileriHazirla(secilenSinif!);
      }
    });
  }

  // Sınıf değişince listeleri sıfırla ve doldur
  void _ogrencileriHazirla(String sinif) async {
    setState(() {
      ekrandakiIsim = "Yükleniyor...";
      tumSinifListesi = [];
      kalanOgrenciler = [];
    });

    List<String> gelenListe = await widget.service.ogrencileriSinifaGoreGetir(sinif);

    if (mounted) {
      setState(() {
        tumSinifListesi = List.from(gelenListe); // Ana kopyayı sakla
        kalanOgrenciler = List.from(gelenListe); // Havuzu doldur
        ekrandakiIsim = "Hazır mısın $sinif?";
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _listeyiSifirla() {
    setState(() {
      kalanOgrenciler = List.from(tumSinifListesi); // Havuzu tekrar fulle
      ekrandakiIsim = "Liste Sıfırlandı! 🔄";
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tüm sınıf tekrar listeye eklendi!"), duration: Duration(seconds: 1)),
    );
  }

  void _sansliKisiyiSec() async {
    if (secilenSinif == null || kalanOgrenciler.isEmpty) {
      if (kalanOgrenciler.isEmpty && tumSinifListesi.isNotEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Herkes seçildi! Listeyi sıfırlayın.")),
        );
      }
      return;
    }

    setState(() {
      isSearching = true;
    });

    int turSayisi = 0;
    
    // Animasyon (Görsel efekt için tüm sınıftan rastgele isimler göster)
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        // Efekt sırasında listedeki herhangi biri görünebilir (heyecan için)
        int randomIndex = Random().nextInt(tumSinifListesi.length);
        String hamIsim = tumSinifListesi[randomIndex];
        ekrandakiIsim = hamIsim.split("(")[0].trim();
      });

      turSayisi++;

      // Animasyon bitince GERÇEK kazananı belirle
      if (turSayisi >= 20) {
        timer.cancel();
        
        // --- KRİTİK NOKTA: Kalanlar arasından seç ---
        int winnerIndex = Random().nextInt(kalanOgrenciler.length);
        String kazananHam = kalanOgrenciler[winnerIndex];
        String kazananTemiz = kazananHam.split("(")[0].trim();

        setState(() {
          ekrandakiIsim = kazananTemiz;
          isSearching = false;
          
          // Seçilen kişiyi havuzdan çıkar (Bir daha seçilmesin)
          kalanOgrenciler.removeAt(winnerIndex);
        });

        _kazananiKutla(kazananTemiz);
      }
    });
  }

  void _kazananiKutla(String isim) {
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
                isim,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 10),
              // Kalan öğrenci bilgisini göster
              Text(
                "Sırada bekleyen: ${kalanOgrenciler.length} kişi kaldı",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
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
                    if(newValue != null) {
                       setState(() => secilenSinif = newValue);
                       _ogrencileriHazirla(newValue);
                    }
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // İsim Kartı
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 300,
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
                
                // Kalan Kişi Sayısı Rozeti (Sağ üst köşe)
                if(tumSinifListesi.isNotEmpty)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: kalanOgrenciler.isEmpty ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Text(
                      "${kalanOgrenciler.length} / ${tumSinifListesi.length}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                )
              ],
            ),
            
            const SizedBox(height: 50),

            // BUTONLAR (YAN YANA)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Çevirme Butonu
                SizedBox(
                  width: 160,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: (isSearching || secilenSinif == null || kalanOgrenciler.isEmpty) 
                      ? null 
                      : _sansliKisiyiSec,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 10,
                    ),
                    child: Text(
                      isSearching ? "..." : "Seç 🎲",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                const SizedBox(width: 15),

                // Sıfırlama Butonu (Küçük Yuvarlak)
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: (isSearching || secilenSinif == null) ? null : _listeyiSifirla,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(), 
                      elevation: 0,
                    ),
                    child: const Icon(Icons.refresh, size: 30),
                  ),
                ),
              ],
            ),
            
            // Eğer liste bittiyse kullanıcıya bilgi ver
            if (kalanOgrenciler.isEmpty && tumSinifListesi.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "Tüm öğrenciler seçildi!\nListeyi sıfırlamak için 🔄 butonuna bas.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
          ],
        ),
      ),
    );
  }
}