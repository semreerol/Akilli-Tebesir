import 'package:hive/hive.dart';

class OdevService {
  late Box _ogrenciKutusu;
  late Box _odevKutusu;
  late Box _kontrolKutusu; // <--- YENİ KUTU

  OdevService() {
    _ogrenciKutusu = Hive.box('ogrenciler');
    _odevKutusu = Hive.box('odevler');
    
    // Eğer main.dart'ta açmayı unuttuysak burada güvenlik için açalım
    // (Normalde main.dart'ta açılmalı ama garanti olsun)
    if (Hive.isBoxOpen('kontrolBox')) {
      _kontrolKutusu = Hive.box('kontrolBox');
    } else {
       // Bu kısım main.dart'ta açılacağı için burası genelde çalışmaz
       // ama kod hatası vermesin diye tanımlıyoruz.
    }
  }
  
  // Bu fonksiyonu main.dart'tan sonra çalışması için init olarak çağırabiliriz
  // veya direkt kullanım anında kutuyu çağırırız.
  Box get kontrolKutusu => Hive.box('kontrolBox');

  // --- ÖĞRENCİ İŞLEMLERİ ---
  Future<void> ogrenciEkle(String adSoyad) async {
    await _ogrenciKutusu.add(adSoyad);
  }

  List<String> ogrencileriGetir() {
    return _ogrenciKutusu.values.cast<String>().toList();
  }

  Future<void> ogrenciSil(int index) async {
    await _ogrenciKutusu.deleteAt(index);
  }

  // --- ÖDEV İŞLEMLERİ ---
  Future<void> odevEkle(String odevKonusu) async {
    await _odevKutusu.add(odevKonusu);
  }

  List<String> odevleriGetir() {
    return _odevKutusu.values.cast<String>().toList();
  }

  Future<void> odevSil(int index) async {
    await _odevKutusu.deleteAt(index);
  }

  // --- YENİ: KONTROL İŞLEMLERİ ---
  
  // Ödev yapıldı mı kontrolü (Örn: "Matematik_Ali" anahtarına bakar)
  bool odevYapildiMi(String odevAdi, String ogrenciAdi) {
    final key = "${odevAdi}_$ogrenciAdi"; // Benzersiz anahtar oluşturuyoruz
    return kontrolKutusu.get(key, defaultValue: false); // Yoksa 'yapılmadı' (false) döner
  }

  // Durumu kaydet (Yapıldı veya Yapılmadı)
  Future<void> odevDurumuDegistir(String odevAdi, String ogrenciAdi, bool durum) async {
    final key = "${odevAdi}_$ogrenciAdi";
    await kontrolKutusu.put(key, durum);
  }
}