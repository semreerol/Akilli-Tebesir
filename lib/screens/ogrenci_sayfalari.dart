import 'package:flutter/material.dart';
import '../odev_service.dart'; // Servis importu

class OgrenciSayfalari extends StatefulWidget {
  final OdevService service;

  const OgrenciSayfalari({super.key, required this.service});

  @override
  State<OgrenciSayfalari> createState() => _OgrenciSayfalariState();
}

class _OgrenciSayfalariState extends State<OgrenciSayfalari> {
  // Öğrencileri tutacağımız liste
  List<String> ogrenciler = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  // Veritabanından verileri çekip ekranı günceller
  void _verileriYukle() {
    setState(() {
      ogrenciler = widget.service.ogrencileriGetir();
    });
  }

  // Yeni Öğrenci Ekleme Penceresi
  void _yeniOgrenciEkle() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Öğrenci Ekle"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Öğrenci Adı Soyadı"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  // Servis üzerinden kaydet
                  await widget.service.ogrenciEkle(_controller.text);
                  _controller.clear();
                  Navigator.pop(context); // Pencereyi kapat
                  _verileriYukle(); // Listeyi yenile
                }
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  // Öğrenci Silme İşlemi
  void _ogrenciSil(int index) async {
    await widget.service.ogrenciSil(index);
    _verileriYukle(); // Listeyi yenile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Öğrenci Listesi"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: ogrenciler.isEmpty
          ? const Center(child: Text("Henüz kayıtlı öğrenci yok."))
          : ListView.builder(
              itemCount: ogrenciler.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orangeAccent,
                      child: Text(ogrenciler[index][0].toUpperCase()), // İsmin baş harfi
                    ),
                    title: Text(ogrenciler[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _ogrenciSil(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _yeniOgrenciEkle,
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}