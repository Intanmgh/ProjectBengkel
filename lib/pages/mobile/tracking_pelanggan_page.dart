import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingPelangganPage extends StatelessWidget {
  const TrackingPelangganPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil data user yang sedang login secara otomatis
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Live Tracking Servis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: currentUser == null
          ? const Center(child: Text("Silakan login terlebih dahulu untuk melihat tracking."))
          : StreamBuilder<QuerySnapshot>(
              // 2. QUERY OTOMATIS: Cari SPK yang email-nya sama dengan email akun yang login
              stream: FirebaseFirestore.instance
                  .collection('spk')
                  .where('email', isEqualTo: currentUser.email) 
                  .orderBy('waktu_dibuat', descending: true)
                  .limit(1) // Hanya ambil 1 data servis yang paling baru
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Jika user belum pernah servis atau tidak ada data SPK
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car_filled_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          "Tidak ada proses servis aktif.",
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Kendaraan Anda saat ini tidak sedang berada\ndalam antrean bengkel kami.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                // 3. JIKA ADA DATA SERVIS, TAMPILKAN PROGRESS-NYA
                final docData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                final statusServis = docData['status'] ?? 'Menunggu';

                // Persiapkan data checklist pekerjaan
                List<Map<String, dynamic>> listPekerjaan = [];
                if (docData['items'] != null) {
                  listPekerjaan = List<Map<String, dynamic>>.from(docData['items']);
                }

                // Kalkulasi Progress Bar
                int totalTugas = listPekerjaan.length;
                int tugasSelesai = listPekerjaan.where((item) => item['status'] == 'Selesai').length;
                double persenProgress = totalTugas > 0 ? (tugasSelesai / totalTugas) : 0.0;

                // Dinamika Warna Status
                Color warnaStatus = Colors.orange;
                if (statusServis == 'Berjalan') warnaStatus = Colors.blue;
                if (statusServis == 'Selesai') warnaStatus = Colors.green;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- BANNER INFORMASI KENDARAAN ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(docData['kendaraan'] ?? 'Mobil Saya', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: warnaStatus.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                  child: Text(statusServis.toUpperCase(), style: TextStyle(color: warnaStatus, fontWeight: FontWeight.bold, fontSize: 11)),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.engineering, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text("Mekanik Bertugas: ${docData['nama_montir'] ?? 'Menunggu mekanik'}", style: const TextStyle(color: Colors.black87, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // --- BANNER PROGRESS BAR (MUNCUL JIKA SUDAH MULAI DIKERJAKAN) ---
                      if (statusServis != 'Menunggu')
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade900,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [BoxShadow(color: Colors.blue.shade900.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Status Pengerjaan", style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("$tugasSelesai dari $totalTugas Selesai", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text("${(persenProgress * 100).toInt()}%", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: persenProgress,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                                  minHeight: 10,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 25),
                      const Text("Detail Penanganan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),

                      // --- DAFTAR CEKLIST PEKERJAAN (READ ONLY) ---
                      if (listPekerjaan.isEmpty)
                        const Text("Belum ada rincian pekerjaan.", style: TextStyle(color: Colors.grey))
                      else
                        ...listPekerjaan.map((item) {
                          bool isSelesai = item['status'] == 'Selesai';
                          bool isDikerjakan = item['status'] == 'Dikerjakan';
                          
                          // Penentuan warna icon berdasarkan status
                          Color iconColor = Colors.grey.shade400;
                          IconData iconData = Icons.radio_button_unchecked;
                          String statusText = "Menunggu antrean";

                          if (isSelesai) {
                            iconColor = Colors.green;
                            iconData = Icons.check_circle;
                            statusText = "Selesai dikerjakan";
                          } else if (isDikerjakan) {
                            iconColor = Colors.blue;
                            iconData = Icons.pending;
                            statusText = "Sedang dikerjakan";
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelesai ? Colors.green.shade50 : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelesai ? Colors.green.shade200 : Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(iconData, color: iconColor, size: 26),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nama'] ?? '-',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isSelesai ? Colors.green.shade900 : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        statusText,
                                        style: TextStyle(color: isSelesai ? Colors.green.shade700 : Colors.grey.shade600, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                );
              },
            ),
    );
  }
}