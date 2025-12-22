import 'package:hive/hive.dart';

part 'odev_model.g.dart';

// 1. ÖĞRENCİ MODELİ
@HiveType(typeId: 1)
class Ogrenci extends HiveObject {
  @HiveField(0)
  late String adSoyad;

  @HiveField(1)
  late String sinif; // Örn: "8-A"

  Ogrenci({required this.adSoyad, required this.sinif});
}

// 2. ÖDEV MODELİ
@HiveType(typeId: 2)
class Odev extends HiveObject {
  @HiveField(0)
  late String baslik;

  @HiveField(1)
  late String sinif; // Bu ödev hangi sınıfa verildi?

  @HiveField(2)
  late DateTime tarih;

  // Bu ödevi tamamlayan öğrencilerin ID'lerini (key) burada saklayacağız
  @HiveField(3)
  List<int> tamamlayanOgrenciKeyleri = [];

  Odev({required this.baslik, required this.sinif, required this.tarih});
}