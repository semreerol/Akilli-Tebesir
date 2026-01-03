import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OdevService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Şu anki öğretmenin ID'sini alır
  String? get currentUserId => _auth.currentUser?.uid;

  // Öğretmenin veritabanındaki özel klasörü (Dökümanı)
  DocumentReference get _teacherDoc {
    if (currentUserId == null) throw Exception("Giriş yapılmamış!");
    return _firestore.collection('teachers').doc(currentUserId);
  }

  // ==========================================
  // 1. SINIF İŞLEMLERİ
  // ==========================================
  Future<List<String>> siniflariGetir() async {
    if (currentUserId == null) return [];
    var snapshot = await _teacherDoc.collection('classes').get();
    if (snapshot.docs.isEmpty) return ["6-A", "7-B", "8-C"]; 
    return snapshot.docs.map((d) => d['name'] as String).toList();
  }

  Future<void> sinifEkle(String sinifAdi) async {
    await _teacherDoc.collection('classes').doc(sinifAdi).set({'name': sinifAdi});
  }

  // ==========================================
  // 2. ÖĞRENCİ LİSTESİ İŞLEMLERİ
  // ==========================================
  Future<List<String>> ogrencileriGetir() async {
    if (currentUserId == null) return [];
    var snapshot = await _teacherDoc.collection('students').orderBy('name').get();
    return snapshot.docs.map((d) => d['name'] as String).toList();
  }

  Future<List<String>> ogrencileriSinifaGoreGetir(String sinif) async {
    var tum = await ogrencileriGetir();
    return tum.where((ogr) => ogr.contains("($sinif)")).toList();
  }

  Future<void> ogrenciEkle(String isim) async {
    await _teacherDoc.collection('students').add({'name': isim});
  }

  Future<void> ogrenciSil(String isim) async {
    var snap = await _teacherDoc.collection('students').where('name', isEqualTo: isim).get();
    for (var doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ==========================================
  // 3. ÖĞRENCİ DETAYLARI (TELEFON & ADRES) 
  // (HATA ALDIĞIN KISIM BURADAYDI - EKLENDİ)
  // ==========================================
  
  Future<void> ogrenciDetayKaydet(String isim, String tel, String adres) async {
    // İsimde "/" gibi karakterler varsa ID hatası vermesin diye temizliyoruz
    String safeId = isim.replaceAll("/", "-");
    await _teacherDoc.collection('student_details').doc(safeId).set({
      'phone': tel,
      'address': adres,
    });
  }

  Future<String> getOgrenciTelefon(String isim) async {
    String safeId = isim.replaceAll("/", "-");
    var doc = await _teacherDoc.collection('student_details').doc(safeId).get();
    if (doc.exists && doc.data() != null) {
      // Data içindeki 'phone' alanını kontrol et, yoksa boş döndür
      var data = doc.data() as Map<String, dynamic>;
      return data['phone'] ?? "";
    }
    return "";
  }

  Future<String> getOgrenciAdres(String isim) async {
    String safeId = isim.replaceAll("/", "-");
    var doc = await _teacherDoc.collection('student_details').doc(safeId).get();
    if (doc.exists && doc.data() != null) {
      var data = doc.data() as Map<String, dynamic>;
      return data['address'] ?? "";
    }
    return "";
  }

  // ==========================================
  // 4. ÖDEV İŞLEMLERİ
  // ==========================================
  Future<void> odevEkle(String odevBasligi) async {
    await _teacherDoc.collection('homeworks').add({
      'title': odevBasligi,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> odevleriGetir() async {
    if (currentUserId == null) return [];
    var snapshot = await _teacherDoc.collection('homeworks').orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((d) => d['title'] as String).toList();
  }

  Future<List<String>> odevleriSinifaGoreGetir(String sinif) async {
    var tum = await odevleriGetir();
    return tum.where((odev) => odev.contains("($sinif)")).toList();
  }

  Future<void> odevSil(String odevBasligi) async {
    var snap = await _teacherDoc.collection('homeworks').where('title', isEqualTo: odevBasligi).get();
    for (var doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ==========================================
  // 5. KONTROL (TIK) İŞLEMLERİ
  // ==========================================
  Future<bool> odevYapildiMi(String odevAdi, String ogrenciAdi) async {
    String checkId = "${odevAdi}_$ogrenciAdi".replaceAll("/", "-");
    var doc = await _teacherDoc.collection('checks').doc(checkId).get();
    if (doc.exists && doc.data() != null) {
      var data = doc.data() as Map<String, dynamic>;
      return data['done'] ?? false;
    }
    return false;
  }

  Future<void> odevDurumuDegistir(String odevAdi, String ogrenciAdi, bool durum) async {
    String checkId = "${odevAdi}_$ogrenciAdi".replaceAll("/", "-");
    await _teacherDoc.collection('checks').doc(checkId).set({
      'done': durum,
      'odev': odevAdi,
      'ogrenci': ogrenciAdi,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // 6. DERS PROGRAMI İŞLEMLERİ
  // (HATA ALDIĞIN DİĞER KISIM - EKLENDİ)
  // ==========================================

  Future<void> dersKaydet(String gun, int saat, String ders) async {
    // Örn: Pazartesi_1
    String docId = "${gun}_$saat";
    await _teacherDoc.collection('schedule').doc(docId).set({
      'lesson': ders
    });
  }
  
  Future<String> dersGetir(String gun, int saat) async {
    String docId = "${gun}_$saat";
    var doc = await _teacherDoc.collection('schedule').doc(docId).get();
    
    if (doc.exists && doc.data() != null) {
      var data = doc.data() as Map<String, dynamic>;
      return data['lesson'] ?? "";
    }
    return "";
  }

  // --- İSTATİSTİK HESAPLAMA (YENİ) ---
  Future<Map<String, dynamic>> getOgrenciIstatistikleri(String ogrenciAdi) async {
    // 1. Öğrencinin sınıfını bul: "Ali (6-A)" -> "6-A"
    String sinif = "";
    if (ogrenciAdi.contains("(") && ogrenciAdi.contains(")")) {
      sinif = ogrenciAdi.split("(").last.replaceAll(")", "").trim();
    }

    // 2. O sınıfa ait tüm ödevleri çek
    var tumOdevler = await odevleriSinifaGoreGetir(sinif);
    int toplamOdevSayisi = tumOdevler.length;
    int yapilanSayisi = 0;
    List<Map<String, dynamic>> odevDetaylari = [];

    // 3. Tek tek kontrol et: Yapıldı mı?
    for (String odev in tumOdevler) {
      bool yapildi = await odevYapildiMi(odev, ogrenciAdi);
      if (yapildi) yapilanSayisi++;
      
      odevDetaylari.add({
        'baslik': odev.split("(")[0].trim(), // Sadece ders adı
        'durum': yapildi
      });
    }

    // 4. Sonuçları paketle
    return {
      'toplam': toplamOdevSayisi,
      'yapilan': yapilanSayisi,
      'yapilmayan': toplamOdevSayisi - yapilanSayisi,
      'basari': toplamOdevSayisi == 0 ? 0 : (yapilanSayisi / toplamOdevSayisi) * 100,
      'liste': odevDetaylari
    };
  }

}