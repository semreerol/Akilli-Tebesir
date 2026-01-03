import 'package:flutter/material.dart';
import '../../services/odev_service.dart';

class DersProgramiSayfasi extends StatefulWidget {
  final OdevService service;

  const DersProgramiSayfasi({super.key, required this.service});

  @override
  State<DersProgramiSayfasi> createState() => _DersProgramiSayfasiState();
}

class _DersProgramiSayfasiState extends State<DersProgramiSayfasi> {
  final List<String> gunler = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma"];
  final int dersSayisi = 8; // Günde 8 ders

  void _dersDuzenle(String gun, int saat, String mevcutDers) {
    TextEditingController _controller = TextEditingController(text: mevcutDers);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$gun - $saat. Ders"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Ders adı giriniz (Örn: Matematik)"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Veritabanına kaydet
                await widget.service.dersKaydet(gun, saat, _controller.text);
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {}); // Ekranı yenile
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Haftalık Ders Programı"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: gunler.length,
        itemBuilder: (context, gunIndex) {
          String gun = gunler[gunIndex];
          return ExpansionTile(
            title: Text(gun, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            // İlk gün açık gelsin, diğerleri kapalı
            initiallyExpanded: gunIndex == 0, 
            children: List.generate(dersSayisi, (index) {
              int saat = index + 1;
              
              return FutureBuilder<String>(
                future: widget.service.dersGetir(gun, saat),
                builder: (context, snapshot) {
                  String dersAdi = "Boş";
                  if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                    dersAdi = snapshot.data!;
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: Text("$saat", style: const TextStyle(color: Colors.indigo)),
                    ),
                    title: Text(dersAdi, style: TextStyle(
                      color: dersAdi == "Boş" ? Colors.grey : Colors.black,
                      fontWeight: dersAdi == "Boş" ? FontWeight.normal : FontWeight.bold
                    )),
                    trailing: const Icon(Icons.edit, size: 18, color: Colors.grey),
                    onTap: () => _dersDuzenle(gun, saat, dersAdi == "Boş" ? "" : dersAdi),
                  );
                },
              );
            }),
          );
        },
      ),
    );
  }
}