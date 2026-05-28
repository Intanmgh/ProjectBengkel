import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_mobile_page.dart';

class DashboardMobilePage extends StatelessWidget {
  const DashboardMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil email user yang sedang login saat ini
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Bengkel", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          // Tombol Logout di pojok kanan atas AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              
              // Tendang kembali ke halaman login mobile
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginMobilePage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, size: 80, color: Colors.blue[800]),
              const SizedBox(height: 15),
              const Text(
                "Selamat Datang di Aplikasi Mobile!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Login sebagai: ${user?.email ?? 'Pengguna'}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // Tempat menaruh menu utama tracking servis nanti
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Text(
                  "Fitur Utama Pendataan Servis & Tracking Kendaraan Akan Muncul Di Sini.",
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}