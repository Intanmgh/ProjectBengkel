import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_mobile_page.dart';
import 'dashboard_mobile_page.dart';
// Note: Nantinya Anda bisa import dashboard_page atau halaman tracking khusus Anda di sini

class LoginMobilePage extends StatefulWidget {
  const LoginMobilePage({super.key});

  @override
  State<LoginMobilePage> createState() => _LoginMobilePageState();
}

class _LoginMobilePageState extends State<LoginMobilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false; // Tambahan agar tombol ada loading saat loading firebase

  Future<void> loginUser() async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Kata Sandi tidak boleh kosong!")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Proses Login Utama ke Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 2. Ambil Data Dokumen User dari Cloud Firestore Koleksi 'users'
      // Note: Jika kawan Anda memakai nama koleksi berbeda (misal: 'pengguna'), ganti tulisan 'users' di bawah
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!mounted) return;

      if (userDoc.exists) {
        // Ambil data role dari dalam dokumen
        String role = userDoc.get('role') ?? 'pelanggan';

        if (role == 'pelanggan') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Sukses Sebagai Pelanggan!"), backgroundColor: Colors.green),
          );
          // ➡️ Diarahkan ke Dashboard Pelanggan
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardMobilePage()), // Sementara ke dashboard utama dulu
          );
        } else if (role == 'montir') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Sukses Sebagai Montir!"), backgroundColor: Colors.blue),
          );
          // ➡️ Nanti di sini kita arahkan ke Halaman Dashboard Montir khusus
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardMontirPage()));
        }
      } else {
        // Kasus jika akun ada di Auth tapi data role-nya belum dibuat di Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data pengguna tidak ditemukan di database Firestore!"), backgroundColor: Colors.orange),
        );
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login gagal: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // 🔵 BAGIAN ATAS: Logo & Identitas (Tetap Proporsional)
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', width: 300), // Sedikit diperkecil dari 160 ke 140
                      const SizedBox(height: 15),
                      const Text(
                        "JIMU MITSUBISHI",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Sistem Manajemen Bengkel untuk Pelayanan Terbaik",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Jarak ke area bawah diperkecil dari 40 ke 30

                // ⚪ BAGIAN BAWAH: Diperkecil & Dirapatkan
                const Text(
                  "Selamat Datang",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Diperkecil dari 26 ke 22
                ),
                const SizedBox(height: 4),
                const Text(
                  "Silahkan masuk untuk mengelola aplikasi mobile",
                  style: TextStyle(color: Colors.black54, fontSize: 13), // Diperkecil ke 13
                ),
                const SizedBox(height: 20), // Jarak diperkecil dari 30 ke 20

                // KOTAK INPUT EMAIL
                const Text(
                  "Alamat Email", 
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13), // Diperkecil ke 13
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 14), // Ukuran teks ketikan lebih kecil
                  decoration: InputDecoration(
                    hintText: "nama@email.com",
                    prefixIcon: const Icon(Icons.email, size: 20), // Icon diperkecil sedikit
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Kolom lebih ramping
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 14), // Jarak antar form diperkecil dari 20 ke 14

                // KOTAK INPUT PASSWORD
                const Text(
                  "Kata Sandi", 
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13), // Diperkecil ke 13
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Kolom lebih ramping
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 20), // Jarak ke tombol diperkecil dari 30 ke 20

                // 🔥 TOMBOL LOGIN
                SizedBox(
                  width: double.infinity,
                  height: 42, // Tinggi tombol dibuat lebih ramping dari 48 ke 42
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isLoading ? null : loginUser,
                    child: isLoading 
                        ? const SizedBox(
                            width: 18, 
                            height: 18, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text("Masuk", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), // Font tombol disesuaikan
                  ),
                ),

                const SizedBox(height: 15), // Jarak ke bawah diperkecil dari 25 ke 15

                // TOMBOL REGISTER
                Center(
                  child: TextButton(
                    onPressed: () {
                      // ➡️ NAVIGASI KE HALAMAN REGISTER MOBILE
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterMobilePage()),
                      );
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero), 
                    child: Text(
                      "Belum punya akun? Daftar disini",
                      style: TextStyle(color: Colors.blue[800], fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}