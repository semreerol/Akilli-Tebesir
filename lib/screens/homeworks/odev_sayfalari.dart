import 'package:flutter/material.dart';
import '../../services/odev_service.dart';
import 'odev_kontrol_sayfasi.dart';

class OdevSayfalari extends StatefulWidget {
  final OdevService service;

  const OdevSayfalari({super.key, required this.service});

  @override
  State<OdevSayfalari> createState() => _OdevSayfalariState();
}

class _OdevSayfalariState extends State<OdevSayfalari> {
  List<String> tumOdevler = [];
  List<String> siniflar = [];
  String? secilenSinifFiltresi;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    setState(() => _yukleniyor = true);
    
    var gelenSiniflar = await widget.service.siniflariGetir();
    List<String> gelenOdevler;

    if (secilenSinifFiltresi != null && secilenSinifFiltresi != "Tümü") {
      gelenOdevler = await widget.service.odevleriSinifaGoreGetir(secilenSinifFiltresi!);
    } else {
      gelenOdevler = await widget.service.odevleriGetir();
    }

    if (mounted) {
      setState(() {
        siniflar = gelenSiniflar;
        tumOdevler = gelenOdevler;
        _yukleniyor = false;
      });
    }
  }

  void _yeniOdevEkle() {
    TextEditingController konuController = TextEditingController();
    String? odevIcinSecilenSinif;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Yeni Ödev Ver"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: konuController,
                    decoration: const InputDecoration(
                      labelText: "Ödev Konusu",
                      hintText: "Örn: Kesirler",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: odevIcinSecilenSinif,
                    hint: const Text("Hangi Sınıfa?"),
                    items: siniflar.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) {
                      setState(() => odevIcinSecilenSinif = val);
                    },
                    decoration: const InputDecoration(border: OutlineInputBorder()),
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
                    if (konuController.text.isNotEmpty && odevIcinSecilenSinif != null) {
                      // Kayıt
                      String tamBaslik = "${konuController.text} ($odevIcinSecilenSinif)";
                      await widget.service.odevEkle(tamBaslik);
                      
                      if(!mounted) return;
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
      },
    );
  }

  void _odevSil(String odevBasligi) async {
    await widget.service.odevSil(odevBasligi);
    _verileriYukle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ödevler"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Colors.indigo,
                icon: const Icon(Icons.filter_list, color: Colors.white),
                value: secilenSinifFiltresi,
                hint: const Text("Filtre", style: TextStyle(color: Colors.white70)),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                items: [
                  const DropdownMenuItem(value: "Tümü", child: Text("Tümü")),
                  ...siniflar.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                ],
                onChanged: (val) {
                  setState(() {
                    secilenSinifFiltresi = val;
                  });
                  _verileriYukle();
                },
              ),
            ),
          ),
        ],
      ),
      body: _yukleniyor 
          ? const Center(child: CircularProgressIndicator())
          : tumOdevler.isEmpty
            ? const Center(child: Text("Henüz ödev yok."))
            : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: tumOdevler.length,
                itemBuilder: (context, index) {
                  String odevMetni = tumOdevler[index];
                  String baslik = odevMetni.split("(")[0].trim();
                  
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        child: const Icon(Icons.assignment, color: Colors.purple),
                      ),
                      title: Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(odevMetni, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _odevSil(odevMetni),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OdevKontrolSayfasi(
                              odevAdi: odevMetni,
                              service: widget.service,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _yeniOdevEkle,
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Ödev Ver", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}