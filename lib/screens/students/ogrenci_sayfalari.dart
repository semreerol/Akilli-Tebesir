import 'package:flutter/material.dart';
import 'package:odev_takip/services/odev_service.dart';
import '../../services/odev_service.dart';
import 'ogrenci_detay_sayfasi.dart';

class OgrenciSayfalari extends StatefulWidget {
  final OdevService service;

  const OgrenciSayfalari({super.key, required this.service});

  @override
  State<OgrenciSayfalari> createState() => _OgrenciSayfalariState();
}

class _OgrenciSayfalariState extends State<OgrenciSayfalari> {
  List<String> ogrenciler = [];
  final TextEditingController _isimController = TextEditingController();
  
  // Sınıf seçimi için değişkenler
  String? _secilenSinif; 
  List<String> kayitliSiniflar = [];

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  void _verileriYukle() {
    setState(() {
      ogrenciler = widget.service.ogrencileriGetir();
      kayitliSiniflar = widget.service.siniflariGetir(); // Sınıfları servisten çek
    });
  }

  void _yeniOgrenciEkle() {
    _isimController.clear();
    _secilenSinif = null; // Sıfırla

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Yeni Öğrenci Ekle"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // İsim Alanı
                  TextField(
                    controller: _isimController,
                    decoration: const InputDecoration(
                      labelText: "Ad Soyad",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // --- HEM YAZILABİLİR HEM SEÇİLEBİLİR ALAN (AUTOCOMPLETE) ---
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      // Eğer boşsa tüm listeyi göster
                      if (textEditingValue.text == '') {
                        return kayitliSiniflar;
                      }
                      // Yazılan harfe göre filtrele
                      return kayitliSiniflar.where((String option) {
                        return option.contains(textEditingValue.text.toUpperCase());
                      });
                    },
                    onSelected: (String selection) {
                      _secilenSinif = selection;
                    },
                    fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: textController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: "Sınıf (Seç veya Yaz)",
                          hintText: "Örn: 9-C",
                          prefixIcon: Icon(Icons.class_),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          // Elle yazılan değeri de alıyoruz
                          _secilenSinif = value.toUpperCase();
                        },
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("İptal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_isimController.text.isNotEmpty && _secilenSinif != null && _secilenSinif!.isNotEmpty) {
                      
                      // 1. Yeni girilen sınıfı veritabanına kaydet (Bir dahaki sefere çıksın diye)
                      await widget.service.sinifEkle(_secilenSinif!);

                      // 2. Öğrenciyi kaydet: "Ahmet (9-C)" formatında
                      String tamIsim = "${_isimController.text} ($_secilenSinif)";
                      await widget.service.ogrenciEkle(tamIsim);
                      
                      Navigator.pop(context);
                      _verileriYukle(); // Listeyi yenile
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lütfen isim ve sınıf giriniz.")),
                      );
                    }
                  },
                  child: const Text("Kaydet"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _ogrenciSil(int index) async {
    await widget.service.ogrenciSil(index);
    _verileriYukle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Öğrenci Listesi"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ogrenciler.isEmpty
          ? const Center(child: Text("Henüz kayıtlı öğrenci yok."))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: ogrenciler.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      child: Text(ogrenciler[index][0].toUpperCase()),
                    ),
                    title: Text(
                      ogrenciler[index], 
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OgrenciDetaySayfasi(
                            studentName: ogrenciler[index],
                            service: widget.service,
                          ),
                        ),
                      ).then((_) {
                        _verileriYukle();
                      });
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _ogrenciSil(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _yeniOgrenciEkle,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}