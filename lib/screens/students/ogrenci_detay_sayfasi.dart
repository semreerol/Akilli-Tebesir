import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // <-- Grafik paketi import edildi
import '../../services/odev_service.dart';

class OgrenciDetaySayfasi extends StatefulWidget {
  final String studentName;
  final OdevService service;

  const OgrenciDetaySayfasi({
    super.key,
    required this.studentName,
    required this.service,
  });

  @override
  State<OgrenciDetaySayfasi> createState() => _OgrenciDetaySayfasiState();
}

class _OgrenciDetaySayfasiState extends State<OgrenciDetaySayfasi> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // İstatistik Değişkenleri
  List<String> tumOdevler = [];
  int yapilanOdevSayisi = 0;
  double basariOrani = 0.0;
  
  // İsim Ayrıştırma
  String gorunenIsim = "";
  String gorunenSinif = "";

  // İletişim Bilgileri
  String veliTelefon = "";
  String ogrenciAdres = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _verileriHazirla();
  }

  void _verileriHazirla() {
    if (widget.studentName.contains("(") && widget.studentName.contains(")")) {
      var parcalar = widget.studentName.split("(");
      gorunenIsim = parcalar[0].trim();
      gorunenSinif = parcalar[1].replaceAll(")", "").trim();
    } else {
      gorunenIsim = widget.studentName;
      gorunenSinif = "Sınıf Yok";
    }

    setState(() {
      tumOdevler = widget.service.odevleriGetir();
      yapilanOdevSayisi = 0;
      for (var odev in tumOdevler) {
        if (widget.service.odevYapildiMi(odev, widget.studentName)) {
          yapilanOdevSayisi++;
        }
      }
      basariOrani = tumOdevler.isEmpty ? 0.0 : yapilanOdevSayisi / tumOdevler.length;

      veliTelefon = widget.service.getOgrenciTelefon(widget.studentName);
      ogrenciAdres = widget.service.getOgrenciAdres(widget.studentName);
    });
  }

  void _bilgileriDuzenle() {
    TextEditingController telController = TextEditingController(text: veliTelefon == "Girilmedi" ? "" : veliTelefon);
    TextEditingController adresController = TextEditingController(text: ogrenciAdres == "Adres girilmedi." ? "" : ogrenciAdres);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Öğrenci Bilgilerini Düzenle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: telController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Veli Telefonu", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: adresController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Ev Adresi", prefixIcon: Icon(Icons.home), border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
            ElevatedButton(
              onPressed: () async {
                await widget.service.ogrenciDetayKaydet(
                  widget.studentName, 
                  telController.text.isEmpty ? "Girilmedi" : telController.text, 
                  adresController.text.isEmpty ? "Adres girilmedi." : adresController.text
                );
                Navigator.pop(context);
                _verileriHazirla();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bilgiler güncellendi!")));
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Öğrenci Detayı"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit), 
            onPressed: _bilgileriDuzenle,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.indigo,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.indigo,
              indicatorWeight: 3,
              tabs: const [Tab(text: "Genel"), Tab(text: "Ödevler"), Tab(text: "Notlar")],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildGenelTab(), _buildOdevlerTab(), _buildNotlarTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.indigo,
      padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20, top: 10),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Text(
                  gorunenIsim.isNotEmpty ? gorunenIsim[0].toUpperCase() : "?",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gorunenIsim, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                    child: Text("$gorunenSinif Sınıfı", style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(Icons.call, "Veli Ara", () {}),
              _buildActionButton(Icons.message, "SMS", () {}),
              _buildActionButton(Icons.message_rounded, "WhatsApp", () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  // --- GRAFİKLİ GENEL BAKIŞ SEKME TASARIMI ---
  Widget _buildGenelTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Performans Grafiği", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 10),
        
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // --- SOL TARAFA CHART (GRAFİK) EKLİYORUZ ---
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 35,
                          startDegreeOffset: -90,
                          sections: [
                            // Dolu Kısım (Başarı)
                            PieChartSectionData(
                              color: Colors.indigo,
                              value: basariOrani * 100,
                              title: "",
                              radius: 12,
                            ),
                            // Boş Kısım (Gri Alan)
                            PieChartSectionData(
                              color: Colors.grey[200],
                              value: (1 - basariOrani) * 100,
                              title: "",
                              radius: 12,
                            ),
                          ],
                        ),
                      ),
                      // Ortadaki Yüzde Yazısı
                      Center(
                        child: Text(
                          "%${(basariOrani * 100).toInt()}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo),
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(width: 20), // Grafik ile yazı arası boşluk

                // --- SAĞ TARAFA DETAYLAR ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressBar("Ödev Katılımı", basariOrani, Colors.green), 
                      const SizedBox(height: 10),
                      _buildProgressBar("Davranış", 0.9, Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        const Text("İletişim Bilgileri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        
        Card(
          margin: const EdgeInsets.only(top: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.indigo),
                title: const Text("Veli Telefonu"),
                subtitle: Text(veliTelefon, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.indigo),
                title: const Text("Adres"),
                subtitle: Text(ogrenciAdres),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOdevlerTab() {
    if (tumOdevler.isEmpty) return const Center(child: Text("Henüz verilmiş bir ödev yok."));
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: tumOdevler.length,
      itemBuilder: (context, index) {
        final odevAdi = tumOdevler[index];
        final bool yapildi = widget.service.odevYapildiMi(odevAdi, widget.studentName);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          color: yapildi ? Colors.white : Colors.grey[100], 
          child: ListTile(
            leading: CircleAvatar(backgroundColor: yapildi ? Colors.green : Colors.grey, child: Icon(yapildi ? Icons.check : Icons.access_time, color: Colors.white)),
            title: Text(odevAdi, style: TextStyle(decoration: yapildi ? TextDecoration.lineThrough : null, color: yapildi ? Colors.black : Colors.black54)),
            subtitle: Text(yapildi ? "Tamamlandı" : "Bekleniyor...", style: TextStyle(color: yapildi ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildNotlarTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("Henüz öğretmen notu eklenmedi."),
          const SizedBox(height: 20),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text("Not Ekle"), style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white))
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
            Text("%${(value * 100).toInt()}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[200],
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }
}