import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Şu anki kullanıcıyı getir
  User? get currentUser => _auth.currentUser;

  // Kullanıcı durumunu dinle (Stream)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- 1. GİRİŞ YAP (SignIn) ---
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      print("Giriş hatası: ${e.toString()}");
      return null;
    }
  }

  // --- 2. KAYIT OL (GÜNCELLENDİ: İsim Alıyor) ---
  Future<User?> signUp(String email, String password, String adSoyad) async {
    try {
      // 1. Kullanıcıyı oluştur
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      User? user = result.user;

      // 2. İsmi profiline işle (Display Name Update)
      if (user != null) {
        await user.updateDisplayName(adSoyad);
        await user.reload(); // Bilgileri tazele
        user = _auth.currentUser; // Tazelenmiş kullanıcıyı al
      }

      return user;
    } catch (e) {
      print("Kayıt hatası: ${e.toString()}");
      return null;
    }
  }

  // --- 3. GOOGLE İLE GİRİŞ ---
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; 

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
      
    } catch (e) {
      print("Google giriş hatası: ${e.toString()}");
      return null;
    }
  }

  // --- 4. ÇIKIŞ YAP ---
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // --- 5. ŞİFRE SIFIRLAMA MAİLİ GÖNDER ---
  Future<void> sifreSifirlamaMailiGonder(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Şifre sıfırlama hatası: $e");
      throw e; // Hatayı arayüze fırlat ki kullanıcıya gösterelim
    }
  }

  // --- 6. DOĞRULAMA MAİLİ GÖNDER ---
  Future<void> dogrulamaMailiGonder() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // --- 7. MAİL DOĞRULANMIŞ MI KONTROL ET ---
  bool isEmailVerified() {
    User? user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }
}