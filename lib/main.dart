import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'screens/auth/giris_sayfasi.dart';
import 'services/odev_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Firebase Başlatılıyor
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Hive Başlatılıyor (Hata almamak için şimdilik tutuyoruz)
  await Hive.initFlutter();
  
  // Eski kutuları açalım ki "Box not found" hatası vermesin
  await Hive.openBox('ogrenciler');
  await Hive.openBox('odevler');
  await Hive.openBox('siniflar');
  await Hive.openBox('kontrolBox');
  await Hive.openBox('ders_programi');
  await Hive.openBox('ogrenci_detaylari');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final odevService = OdevService();
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Akıllı Tebeşir',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: LoginPage(service: odevService), 
    );
  }
}