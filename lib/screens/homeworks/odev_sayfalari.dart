import 'package:flutter/material.dart';
import 'package:odev_takip/screens/homeworks/odev_kontrol_sayfasi.dart';
import '../../services/odev_service.dart';

class OdevSayfalari extends StatefulWidget {
  final OdevService service;

  const OdevSayfalari({super.key, required this.service});

  @override
  State<OdevSayfalari> createState() => _OdevSayfalariState();
}

class _OdevSayfalariState extends State<OdevSayfalari> {
  List<String> odevler = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  void _verileriYukle() {
    setState(() {
      odevler = widget.service.odevleriGetir();
    });
  }

  void _yeniOdevEkle() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Ödev Ekle"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Ödev Konusu (Örn: Matematik Sayfa 10)"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  await widget.service.odevEkle(_controller.text);
                  _controller.clear();
                  Navigator.pop(context);
                  _verileriYukle();
                }
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  void _odevSil(int index) async {
    await widget.service.odevSil(index);
    _verileriYukle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ödevler"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: odevler.isEmpty
          ? const Center(child: Text("Henüz eklenen ödev yok."))
          : ListView.builder(
              itemCount: odevler.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.book, color: Colors.purple),
                    title: Text(odevler[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _odevSil(index),
                    ),
                  onTap: () {
        // Ödeve tıklanınca kontrol sayfasına git
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OdevKontrolSayfasi(
              odevAdi: odevler[index], // Hangi ödeve tıklandığını gönderiyoruz
              service: widget.service,
            ),
          ),
        );
      },

                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _yeniOdevEkle,
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}