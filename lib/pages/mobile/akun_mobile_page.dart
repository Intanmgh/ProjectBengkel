import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../mobile/login_mobile_page.dart';

class AkunMobilePage extends StatefulWidget {
  const AkunMobilePage({super.key});

  @override
  State<AkunMobilePage> createState() => _AkunMobilePageState();
}

class _AkunMobilePageState extends State<AkunMobilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  // Variabel penampung data awal sebelum data dari pendaftaran berhasil dimuat
  String namaPelanggan = "Memuat nama...";
  String emailPelanggan = "Memuat email...";
  String nomorTelepon = "Memuat nomor...";

  @override
  void initState() {
    super.initState();
    _ambilDataPelanggan();
  }

  // 🔄 FUNGSI OTOMATIS MENGAMBIL DATA DARI PENDAFTARAN FIRESTORE
  Future<void> _ambilDataPelanggan() async {
    if (currentUser != null) {
      try {
        // Mengambil dokumen berdasarkan UID user yang sedang login saat ini
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users') // ⚠️ Pastikan nama koleksi ini sama dengan saat kamu simpan di halaman Register
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists && mounted) {
          // Data berhasil ditemukan, ambil nilainya berdasarkan nama key/field di database
          setState(() {
            // 📝 CATATAN: Sesuaikan teks di dalam tanda kurung ['...'] dengan nama field di Firestore pendaftaranmu
            namaPelanggan = userDoc['nama'] ?? 'Tanpa Nama';
            emailPelanggan = userDoc['email'] ?? currentUser!.email ?? '-';
            nomorTelepon = userDoc['telepon'] ?? userDoc['noHp'] ?? '-'; // antisipasi kalau nama field-nya 'noHp'
          });
        } else {
          // Jika dokumen tidak ditemukan di Firestore, pakai data default dari Firebase Auth
          if (mounted) {
            setState(() {
              namaPelanggan = currentUser!.displayName ?? "Pelanggan Jimu";
              emailPelanggan = currentUser!.email ?? "-";
              nomorTelepon = currentUser!.phoneNumber ?? "-";
            });
          }
        }
      } catch (e) {
        debugPrint("Gagal mengambil data pendaftaran: $e");
      }
    }
  }

  // Fungsi Logout aman langsung menuju halaman login
  Future<void> _prosesLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Apakah Anda yakin ingin keluar dari akun Jimu Mitsubishi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              await FirebaseAuth.instance.signOut();
              
              if (mounted) {
                // 🔄 Mengembalikan user langsung ke halaman login (Ganti 'LoginPage' dengan class loginmu)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginMobilePage()), 
                  (route) => false,
                );
              }
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Profil Akun",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= KARTU UTAMA PROFIL =================
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.red.shade50,
                        child: Icon(Icons.person, size: 60, color: Colors.red.shade700),
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.red.shade700,
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 🏷️ OTOMATIS BERUBAH MENJADI NAMA PENDAFTAR
                  Text(
                    namaPelanggan,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  // 🏷️ OTOMATIS BERUBAH MENJADI EMAIL PENDAFTAR
                  Text(
                    emailPelanggan,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),

            // ================= SEKSI DETAIL INFORMASI =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Informasi Pribadi",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // 🏷️ OTOMATIS BERUBAH MENJADI NOMOR HP PENDAFTAR
                  _buildInfoTile(Icons.phone_android, "Nomor Telepon", nomorTelepon),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _buildInfoTile(Icons.verified_user_outlined, "Status Akun", "Pelanggan"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= SEKSI PENGATURAN & AKSI =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Pengaturan Aplikasi",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildMenuTile(Icons.history, "Riwayat Servis Mobil", () {}),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _buildMenuTile(Icons.lock_outline, "Ubah Kata Sandi", () {}),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _buildMenuTile(
                    Icons.logout, 
                    "Keluar dari Akun", 
                    _prosesLogout, 
                    textColor: Colors.red, 
                    iconColor: Colors.red
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            Text(
              "Jimu Mitsubishi v1.0.0",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {Color textColor = Colors.black87, Color iconColor = Colors.blueGrey}) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
      onTap: onTap,
    );
  }
}