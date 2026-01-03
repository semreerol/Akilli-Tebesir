import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Grafik Kütüphanesi
import '../../services/odev_service.dart';

class OgrenciDetaySayfasi extends StatefulWidget {
  final String studentName;
  final OdevService service;

  const OgrenciDetaySayfasi({super.key, required this.studentName, required this.service});

  @override
  State<OgrenciDetaySayfasi> createState() => _OgrenciDetaySayfasiState();
}

class _OgrenciDetaySayfasiState extends State<OgrenciDetaySayfasi> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Form Kontrolcüleri
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  // İstatistik Verileri
  bool _yukleniyor = true;
  int _toplamOdev = 0;
  int _yapilanOdev = 0;
  int _yapilmayanOdev = 0;
  double _basariOrani = 0;
  List<Map<String, dynamic>> _odevListesi = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    // 1. İletişim Bilgilerini Çek
    String tel = await widget.service.getOgrenciTelefon(widget.studentName);
    String adres = await widget.service.getOgrenciAdres(widget.studentName);

    // 2. İstatistikleri Çek (Yeni Metot)
    var istatistik = await widget.service.getOgrenciIstatistikleri(widget.studentName);

    if (mounted) {
      setState(() {
        _phoneController.text = tel;
        _addressController.text = adres;
        
        _toplamOdev = istatistik['toplam'];
        _yapilanOdev = istatistik['yapilan'];
        _yapilmayanOdev = istatistik['yapilmayan'];
        _basariOrani = istatistik['basari']; // Double olabilir (örn: 0.0)
        _odevListesi = istatistik['liste'];
        
        _yukleniyor = false;
      });
    }
  }

  Future<void> _iletisimKaydet() async {
    await widget.service.ogrenciDetayKaydet(
      widget.studentName, 
      _phoneController.text, 
      _addressController.text
    );
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bilgiler Güncellendi ✅")));
  }

  @override
  Widget build(BuildContext context) {
    String gorunenIsim = widget.studentName.split("(")[0].trim();
    String sinifBilgisi = widget.studentName.contains("(") 
        ? widget.studentName.split("(")[1].replaceAll(")", "") 
        : "";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Öğrenci Profili"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: "Genel Durum", icon: Icon(Icons.analytics)),
            Tab(text: "İletişim Bilgileri", icon: Icon(Icons.contact_phone)),
          ],
        ),
      ),
      body: _yukleniyor 
        ? const Center(child: CircularProgressIndicator()) 
        : TabBarView(
            controller: _tabController,
            children: [
              // --- TAB 1: İSTATİSTİKLER ---
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Üst Bilgi Kartı
                    _buildHeaderCard(gorunenIsim, sinifBilgisi),
                    const SizedBox(height: 20),
                    
                    // Grafik ve Oranlar
                    if (_toplamOdev > 0)
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      value: _yapilanOdev.toDouble(),
                                      color: Colors.green,
                                      title: '$_yapilanOdev',
                                      radius: 40,
                                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                    ),
                                    PieChartSectionData(
                                      value: _yapilmayanOdev.toDouble(),
                                      color: Colors.redAccent,
                                      title: '$_yapilmayanOdev',
                                      radius: 40,
                                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                    ),
                                  ],
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 30,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLegend(Colors.green, "Yapılan: $_yapilanOdev"),
                                  const SizedBox(height: 8),
                                  _buildLegend(Colors.redAccent, "Eksik: $_yapilmayanOdev"),
                                  const SizedBox(height: 15),
                                  Text(
                                    "Başarı: %${_basariOrani.toStringAsFixed(0)}",
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    else 
                      const Card(child: Padding(padding: EdgeInsets.all(20), child: Text("Henüz bu sınıfa ödev verilmemiş."))),

                    const SizedBox(height: 20),
                    const Align(alignment: Alignment.centerLeft, child: Text("Ödev Geçmişi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 10),

                    // Ödev Listesi
                    ..._odevListesi.map((odev) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: Icon(
                          odev['durum'] ? Icons.check_circle : Icons.cancel,
                          color: odev['durum'] ? Colors.green : Colors.red,
                        ),
                        title: Text(odev['baslik'], style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(odev['durum'] ? "Tamamlandı" : "Yapılmadı"),
                      ),
                    )),
                  ],
                ),
              ),

              // --- TAB 2: İLETİŞİM ---
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.contact_mail, size: 80, color: Colors.indigo),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Veli Telefonu",
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _addressController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Ev Adresi / Notlar",
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _iletisimKaydet,
                        icon: const Icon(Icons.save),
                        label: const Text("Bilgileri Güncelle"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildHeaderCard(String isim, String sinif) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo, Colors.indigo.shade800]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Text(isim.isNotEmpty ? isim[0] : "?", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.indigo)),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isim, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                child: Text("$sinif Sınıfı", style: const TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}