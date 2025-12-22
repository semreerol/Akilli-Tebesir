import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Dosya yollarını kontrol et
import 'models/teacher.dart';
import 'screens/giris_sayfasi.dart';
import 'odev_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TeacherAdapter());

  await Hive.openBox<Teacher>('teachersBox');
  await Hive.openBox('ogrenciler');
  await Hive.openBox('odevler');
  
  // --- BU SATIRI MUTLAKA EKLE ---
  await Hive.openBox('kontrolBox'); // Ödev kontrol verileri burada tutulacak
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final odevService = OdevService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Öğretmen Asistanı',
      
      // --- TASARIM AYARLARI ---
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        
        // Hata veren 'cardTheme' kısmını kaldırdık. 
        // Uygulama varsayılan kart tasarımını kullanacak.

        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      
      home: LoginPage(service: odevService),
    );
  }
}