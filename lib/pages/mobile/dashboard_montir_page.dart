import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardMontirPage extends StatefulWidget {
  const DashboardMontirPage({super.key});

  @override
  State<DashboardMontirPage> createState() => _DashboardMontirPageState();
}

class _DashboardMontirPageState extends State<DashboardMontirPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() { // ✅ DIPERBAIKI: Menggunakan initState bawaan Flutter
    super.initState();
    // Memiliki 3 tab: Menunggu, Berjalan, Selesai seperti pada image_979ade.png
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER (Sesuai image_979ade.png) =================
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 5, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.car_repair, color: Colors.red, size: 40);
                    },
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "JIMU MITSUBISHI",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text("Bengkel Terbaik", style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Halo, Mekanik Budi",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    radius: 18,
                    child: const Icon(Icons.engineering, color: Colors.orange, size: 20),
                  ),
                ],
              ),
            ),

            // ================= SUMMARY CARDS (Tugas Hari Ini & Selesai) =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // Card Tugas Hari Ini
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tugas Hari Ini", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic, // ✅ DIPERBAIKI: Menggunakan textBaseline di dalam Row
                            children: [
                              Text(
                                "3", 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.blue.shade700),
                              ),
                              const SizedBox(width: 4),
                              Text("Unit", style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Card Selesai
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Selesai", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic, // ✅ DIPERBAIKI: Menggunakan textBaseline di dalam Row
                            children: [
                              Text(
                                "1", 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.green.shade600),
                              ),
                              const SizedBox(width: 4),
                              Text("Unit", style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= TAB BAR DAFTAR ANTREAN SPK =================
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Daftar Antrean SPK",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.blue.shade700,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.blue.shade700,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                tabs: const [
                  Tab(text: "Menunggu (3)"),
                  Tab(text: "Berjalan"),
                  Tab(text: "Selesai"),
                ],
              ),
            ),

            // ================= LIST VIEW SPK CONTENT =================
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. TAB MENUNGGU
                  _buildTabMenunggu(),

                  // 2. TAB BERJALAN
                  const Center(child: Text("Tidak ada servis yang sedang berjalan", style: TextStyle(color: Colors.grey))),

                  // 3. TAB SELESAI
                  const Center(child: Text("Belum ada servis selesai hari ini", style: TextStyle(color: Colors.grey))),
                ],
              ),
            ),
          ],
        ),
      ),

      // ================= BOTTOM NAVIGATION BAR =================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: Colors.blue.shade800,
          unselectedItemColor: Colors.grey.shade600,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Beranda"),
            BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Servis"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Akun"),
          ],
        ),
      ),
    );
  }

  // Widget builder khusus isi antrean "Menunggu" sesuai visual mockup
  Widget _buildTabMenunggu() {
    final List<Map<String, dynamic>> dummySPK = [
      {
        "plat": "BE 3455 YB",
        "mobil": "Mitsubishi Xpander",
        "layanan": "Tune Up",
        "jam": "08:30 WIB"
      },
      {
        "plat": "BE 3455 YB",
        "mobil": "Mitsubishi Xpander",
        "layanan": "Tune Up, Ganti Oli, Servis Kaki-kaki",
        "jam": "10:30 WIB"
      }
    ];

    return ListView.builder(
      itemCount: dummySPK.length,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemBuilder: (context, index) {
        final item = dummySPK[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14), // ✅ DIPERBAIKI: Menggunakan EdgeInsets.only
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.blue.shade100, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris Status & Jam Masuk
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(), 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "MENUNGGU",
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("MASUK", style: TextStyle(color: Colors.blue.shade200, fontSize: 9, fontWeight: FontWeight.bold)),
                      Text(item["jam"], style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
              
              // Detail Kendaraan
              Transform.translate(
                offset: const Offset(0, -30), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["plat"],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item["mobil"],
                      style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              // Jenis Pekerjaan / Layanan
              Row(
                children: [
                  Icon(Icons.build, size: 16, color: Colors.blueGrey.shade400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item["layanan"],
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tombol Mulai Kerja
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Masukkan aksi transisi status SPK di sini
                  },
                  icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 20),
                  label: const Text(
                    "MULAI KERJA",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}