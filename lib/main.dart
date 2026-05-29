import 'package:flutter/foundation.dart'; // Tambahan: Wajib untuk mendeteksi kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/auth/login_page.dart'; // Ini halaman login Web kawan Anda
import 'pages/mobile/login_mobile_page.dart'; // Tambahan: Ini halaman login Mobile Anda

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bengkel Mitsubishi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // LOGIKA PEMISAH JALUR:
      // Jika dibuka di browser Chrome (Web), dia memanggil LoginPage() 
      // Jika dibuka di Emulator/HP Android, dia otomatis memanggil LoginMobilePage() 
      home: kIsWeb 
          ? const LoginPage() 
          : const LoginMobilePage(),
    );
  }
}