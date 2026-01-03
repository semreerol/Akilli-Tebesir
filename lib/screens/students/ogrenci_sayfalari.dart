import 'package:flutter/material.dart';
import '../../services/odev_service.dart';
import 'ogrenci_detay_sayfasi.dart'; // Artık temiz olduğu için hata vermeyecek

class OgrenciSayfalari extends StatefulWidget {
  final OdevService service;

  const OgrenciSayfalari({super.key, required this.service});

  @override
  State<OgrenciSayfalari> createState() => _OgrenciSayfalariState();
}

class _OgrenciSayfalariState extends State<OgrenciSayfalari> {
  List<String> ogrenciler = [];
  bool _yukleniyor = true;
  
  String? _secilenSinif; 
  List<String> kayitliSiniflar = [];

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    setState(() => _yukleniyor = true);
    
    var gelenOgrenciler = await widget.service.ogrencileriGetir();
    var gelenSiniflar = await widget.service.siniflariGetir();

    if (mounted) {
      setState(() {
        ogrenciler = gelenOgrenciler;
        kayitliSiniflar = gelenSiniflar;
        _yukleniyor = false;
      });
    }
  }

  void _yeniOgrenciEkle() {
    TextEditingController _isimController = TextEditingController();
    _secilenSinif = null;

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
                  TextField(
                    controller: _isimController,
                    decoration: const InputDecoration(
                      labelText: "Ad Soyad",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return kayitliSiniflar;
                      }
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
                      
                      Navigator.pop(context); 
                      
                      await widget.service.sinifEkle(_secilenSinif!);
                      String tamIsim = "${_isimController.text} ($_secilenSinif)";
                      await widget.service.ogrenciEkle(tamIsim);
                      
                      _verileriYukle(); 
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

  void _ogrenciSil(String isim) async {
    await widget.service.ogrenciSil(isim);
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
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : ogrenciler.isEmpty
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
                          // BURADAKİ HATA ŞİMDİ GİDECEK
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OgrenciDetaySayfasi(
                                studentName: ogrenciler[index],
                                service: widget.service,
                              ),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _ogrenciSil(ogrenciler[index]),
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