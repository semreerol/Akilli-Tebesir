import 'package:flutter/material.dart';
import '../../services/odev_service.dart';

class OdevKontrolSayfasi extends StatefulWidget {
  final String odevAdi;
  final OdevService service;

  const OdevKontrolSayfasi({super.key, required this.odevAdi, required this.service});

  @override
  State<OdevKontrolSayfasi> createState() => _OdevKontrolSayfasiState();
}

class _OdevKontrolSayfasiState extends State<OdevKontrolSayfasi> {
  List<String> ogrenciler = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _ogrencileriYukle();
  }

  void _ogrencileriYukle() async {
    // Ödev isminden sınıfı bul: "Matematik (6-A)" -> "6-A"
    String hedefSinif = "";
    if (widget.odevAdi.contains("(") && widget.odevAdi.endsWith(")")) {
      var parcalar = widget.odevAdi.split("(");
      hedefSinif = parcalar.last.replaceAll(")", "").trim();
    }

    List<String> gelenler;
    if (hedefSinif.isNotEmpty) {
      gelenler = await widget.service.ogrencileriSinifaGoreGetir(hedefSinif);
    } else {
      gelenler = await widget.service.ogrencileriGetir();
    }

    if (mounted) {
      setState(() {
        ogrenciler = gelenler;
        _yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String baslik = widget.odevAdi.split("(")[0].trim();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: const TextStyle(fontSize: 18)),
            const Text("Kontrol Listesi", style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : ogrenciler.isEmpty
              ? const Center(child: Text("Bu sınıfta öğrenci yok."))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: ogrenciler.length,
                  itemBuilder: (context, index) {
                    final ogrenci = ogrenciler[index];
                    String gorunenIsim = ogrenci.split("(")[0].trim();

                    // HER SATIR İÇİN VERİTABANINDAN DURUMU ÇEKİYORUZ
                    return FutureBuilder<bool>(
                      future: widget.service.odevYapildiMi(widget.odevAdi, ogrenci),
                      builder: (context, snapshot) {
                        bool yapildi = snapshot.data ?? false;

                        return Card(
                          color: yapildi ? Colors.green.shade50 : Colors.white,
                          child: CheckboxListTile(
                            activeColor: Colors.green,
                            title: Text(
                              gorunenIsim,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: yapildi ? Colors.green.shade800 : Colors.black,
                                decoration: yapildi ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: Text(
                              yapildi ? "Tamamlandı" : "Yapılmadı",
                              style: TextStyle(color: yapildi ? Colors.green : Colors.redAccent),
                            ),
                            value: yapildi,
                            onChanged: (yeniDurum) async {
                              if (yeniDurum != null) {
                                // Veritabanına kaydet
                                await widget.service.odevDurumuDegistir(
                                  widget.odevAdi, 
                                  ogrenci, 
                                  yeniDurum
                                );
                                // Ekranı yenile (Bu satır setState ile tüm listeyi değil, sadece FutureBuilder'ı tetiklese daha iyi olurdu ama şimdilik setState ile tüm sayfayı yenilemek en garantisidir)
                                setState(() {});
                              }
                            },
                            secondary: CircleAvatar(
                              backgroundColor: yapildi ? Colors.green : Colors.grey.shade300,
                              foregroundColor: Colors.white,
                              child: Icon(yapildi ? Icons.check : Icons.person),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}