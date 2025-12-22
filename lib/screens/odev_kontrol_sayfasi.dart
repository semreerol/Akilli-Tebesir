import 'package:flutter/material.dart';
import '../odev_service.dart';

class OdevKontrolSayfasi extends StatefulWidget {
  final String odevAdi;
  final OdevService service;

  const OdevKontrolSayfasi({
    super.key, 
    required this.odevAdi, 
    required this.service
  });

  @override
  State<OdevKontrolSayfasi> createState() => _OdevKontrolSayfasiState();
}

class _OdevKontrolSayfasiState extends State<OdevKontrolSayfasi> {
  List<String> ogrenciler = [];

  @override
  void initState() {
    super.initState();
    // Sayfa açılınca öğrencileri yükle
    ogrenciler = widget.service.ogrencileriGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.odevAdi), // Başlıkta ödevin adı yazar
        backgroundColor: Colors.indigo,
      ),
      body: ogrenciler.isEmpty
          ? const Center(child: Text("Sınıfta hiç öğrenci yok."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ogrenciler.length,
              itemBuilder: (context, index) {
                final ogrenciAdi = ogrenciler[index];
                
                // Veritabanından bu öğrencinin bu ödevi yapıp yapmadığını soruyoruz
                bool yapildi = widget.service.odevYapildiMi(widget.odevAdi, ogrenciAdi);

                return Card(
                  color: yapildi ? Colors.green[50] : Colors.white, // Yapıldıysa yeşilimsi olur
                  child: CheckboxListTile(
                    activeColor: Colors.green,
                    title: Text(
                      ogrenciAdi,
                      style: TextStyle(
                        fontSize: 18,
                        decoration: yapildi ? TextDecoration.lineThrough : null, // Yapıldıysa üstünü çiz
                        color: yapildi ? Colors.green : Colors.black,
                      ),
                    ),
                    subtitle: Text(yapildi ? "Tamamlandı" : "Bekleniyor..."),
                    value: yapildi,
                    onChanged: (yeniDurum) {
                      setState(() {
                        // Tik işaretini veritabanına kaydet
                        widget.service.odevDurumuDegistir(
                          widget.odevAdi, 
                          ogrenciAdi, 
                          yeniDurum ?? false
                        );
                      });
                    },
                    secondary: CircleAvatar(
                      backgroundColor: yapildi ? Colors.green : Colors.grey,
                      child: Icon(yapildi ? Icons.check : Icons.person, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
    );
  }
}