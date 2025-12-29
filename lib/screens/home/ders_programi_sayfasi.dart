import 'package:flutter/material.dart';
import '../../services/odev_service.dart';

class DersProgramiSayfasi extends StatefulWidget {
  final OdevService service;

  const DersProgramiSayfasi({super.key, required this.service});

  @override
  State<DersProgramiSayfasi> createState() => _DersProgramiSayfasiState();
}

class _DersProgramiSayfasiState extends State<DersProgramiSayfasi> {
  // Günler Listesi
  final List<String> gunler = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma"];

  // Ders Ekleme/Düzenleme Penceresi
  void _dersDuzenle(String gun, int saat, String mevcutDers) {
    TextEditingController controller = TextEditingController(text: mevcutDers);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$gun - $saat. Ders"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Örn: 6-A Matematik",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.class_),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Veritabanına kaydet
                await widget.service.dersKaydet(gun, saat, controller.text);
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
    return DefaultTabController(
      length: gunler.length, // 5 Gün
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Haftalık Ders Programı"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          bottom: TabBar(
            isScrollable: true, // Sığmazsa kaydırılabilsin
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: gunler.map((gun) => Tab(text: gun)).toList(),
          ),
        ),
        body: TabBarView(
          children: gunler.map((gun) {
            return _buildGunlukListe(gun);
          }).toList(),
        ),
      ),
    );
  }

  // Her gün için 8 saatlik liste oluşturan widget
  Widget _buildGunlukListe(String gun) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8, // Günde 8 ders varsaydık
      itemBuilder: (context, index) {
        int dersSaati = index + 1;
        // O saatteki dersi veritabanından çek
        String dersAdi = widget.service.dersGetir(gun, dersSaati);
        bool bosMu = dersAdi.isEmpty;

        return Card(
          elevation: bosMu ? 1 : 3,
          color: bosMu ? Colors.grey[50] : Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: bosMu ? Colors.grey[300] : Colors.indigo,
              foregroundColor: Colors.white,
              child: Text("$dersSaati"),
            ),
            title: Text(
              bosMu ? "Boş Ders" : dersAdi,
              style: TextStyle(
                fontWeight: bosMu ? FontWeight.normal : FontWeight.bold,
                color: bosMu ? Colors.grey : Colors.black87,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit, color: bosMu ? Colors.grey : Colors.indigo),
              onPressed: () => _dersDuzenle(gun, dersSaati, dersAdi),
            ),
            onTap: () => _dersDuzenle(gun, dersSaati, dersAdi),
          ),
        );
      },
    );
  }
}