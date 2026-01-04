import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/giris_sayfasi.dart';
import 'screens/home/ana_sayfa.dart';
import 'services/odev_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Servisi burada oluşturuyoruz
    final OdevService odevService = OdevService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Akıllı Tebeşir',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      // Uygulama açılışında kontrol ediyoruz:
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // Kullanıcı durumunu dinle
        builder: (context, snapshot) {
          // Eğer bağlantı bekleniyorsa loading dön
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Eğer kullanıcı verisi varsa (Giriş yapmışsa) -> ANA SAYFAYA GİT
          if (snapshot.hasData) {
            return AnaSayfa(
              service: odevService,
              teacherName: snapshot.data!.displayName ?? "Öğretmenim", // İsim yoksa varsayılan
            );
          }

          // Giriş yapmamışsa -> GİRİŞ SAYFASINA GİT
          return LoginPage(service: odevService);
        },
      ),
    );
  }
}