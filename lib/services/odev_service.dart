import 'package:hive/hive.dart';

class OdevService {
  late Box _ogrenciKutusu;
  late Box _odevKutusu;
  late Box _kontrolKutusu;
  late Box _siniflarKutusu;
  late Box _detayKutusu;
  late Box _dersProgramiKutusu;

  OdevService() {
    // KUTULARI TANIMLAMA
    // main.dart'ta açtığımız kutuları burada değişkenlere atıyoruz.
    _ogrenciKutusu = Hive.box('ogrenciler');
    _odevKutusu = Hive.box('odevler');
    _kontrolKutusu = Hive.box('kontrolBox');
    _siniflarKutusu = Hive.box('siniflar');
    if (Hive.isBoxOpen('ogrenci_detaylari')) {
  _detayKutusu = Hive.box('ogrenci_detaylari');
}
    if (Hive.isBoxOpen('ders_programi')) {
  _dersProgramiKutusu = Hive.box('ders_programi');
}
  }

  // --- ÖĞRENCİ İŞLEMLERİ ---
  
  // Öğrenci Ekle
  Future<void> ogrenciEkle(String adSoyad) async {
    await _ogrenciKutusu.add(adSoyad);
  }

  // Öğrencileri Getir
  List<String> ogrencileriGetir() {
    return _ogrenciKutusu.values.cast<String>().toList();
  }

  // Öğrenci Sil
  Future<void> ogrenciSil(int index) async {
    await _ogrenciKutusu.deleteAt(index);
  }

  // --- ÖDEV İŞLEMLERİ ---

  // Ödev Ekle
  Future<void> odevEkle(String odevKonusu) async {
    await _odevKutusu.add(odevKonusu);
  }

  // Ödevleri Getir
  List<String> odevleriGetir() {
    return _odevKutusu.values.cast<String>().toList();
  }

  // Ödev Sil
  Future<void> odevSil(int index) async {
    await _odevKutusu.deleteAt(index);
  }

  // --- KONTROL (TIK) İŞLEMLERİ ---
  
  // Ödev yapıldı mı kontrolü
  bool odevYapildiMi(String odevAdi, String ogrenciAdi) {
    final key = "${odevAdi}_$ogrenciAdi"; 
    // _kontrolKutusu değişkenini kullanıyoruz
    return _kontrolKutusu.get(key, defaultValue: false); 
  }

  // Durumu kaydet (Yapıldı/Yapılmadı)
  Future<void> odevDurumuDegistir(String odevAdi, String ogrenciAdi, bool durum) async {
    final key = "${odevAdi}_$ogrenciAdi";
    await _kontrolKutusu.put(key, durum);
  }

  // --- SINIF İŞLEMLERİ ---

  // Kayıtlı sınıfları getir
  List<String> siniflariGetir() {
    // Eğer kutu boşsa varsayılan sınıfları döndür
    if (_siniflarKutusu.isEmpty) {
      return ["5-A", "6-A", "7-A", "8-A"]; 
    }
    // Doluysa kayıtlı olanları döndür
    return _siniflarKutusu.values.cast<String>().toList();
  }

  // Yeni sınıf kaydet
  Future<void> sinifEkle(String sinifAdi) async {
    // Aynı sınıf daha önce eklenmemişse ekle
    if (!_siniflarKutusu.values.contains(sinifAdi)) {
      await _siniflarKutusu.add(sinifAdi);
    }
  }
  Future<void> ogrenciDetayKaydet(String ogrenciIsmi, String telefon, String adres) async {
    // "Ahmet (6-A)_tel" gibi benzersiz anahtarlar oluşturuyoruz
    await _detayKutusu.put("${ogrenciIsmi}_tel", telefon);
    await _detayKutusu.put("${ogrenciIsmi}_adres", adres);
  }

  // Detay Getir (Telefon)
  String getOgrenciTelefon(String ogrenciIsmi) {
    return _detayKutusu.get("${ogrenciIsmi}_tel", defaultValue: "Girilmedi");
  }

  // Detay Getir (Adres)
  String getOgrenciAdres(String ogrenciIsmi) {
    return _detayKutusu.get("${ogrenciIsmi}_adres", defaultValue: "Adres girilmedi.");
  }

  // Ders Kaydet (Örn: gun="Pazartesi", saat=1, ders="6-A Mat")
  Future<void> dersKaydet(String gun, int saat, String ders) async {
    await _dersProgramiKutusu.put("${gun}_$saat", ders);
  }

  // Ders Getir
  String dersGetir(String gun, int saat) {
    // Eğer kayıt yoksa "Boş" dönsün
    return _dersProgramiKutusu.get("${gun}_$saat", defaultValue: "");
  }
}