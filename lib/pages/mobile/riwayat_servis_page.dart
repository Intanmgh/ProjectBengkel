import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Jangan lupa tambahkan package intl di pubspec.yaml untuk format tanggal

class RiwayatServisPage extends StatefulWidget {
  const RiwayatServisPage({super.key});

  @override
  State<RiwayatServisPage> createState() => _RiwayatServisPageState();
}

class _RiwayatServisPageState extends State<RiwayatServisPage> {
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Fungsi untuk memformat Timestamp Firebase menjadi tanggal yang mudah dibaca
  String formatTanggal(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (currentUid.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Sesi login tidak valid.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Riwayat Kerja Anda"),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil semua SPK milik montir aktif yang statusnya sudah 'Selesai'
        stream: FirebaseFirestore.instance
            .collection('spk')
            .where('montir_uid', isEqualTo: currentUid)
            .where('status', isEqualTo: 'Selesai')
            .orderBy('waktu_selesai', descending: true) // Menampilkan yang paling baru selesai di atas
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off_rounded, size: 70, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    "Belum ada riwayat servis yang diselesaikan.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Bagian Atas: No Plat & Badge Selesai ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['plat'] ?? '-',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 12),
                              SizedBox(width: 4),
                              Text("Selesai", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // --- Bagian Tengah: Detail Informasi Mobil ---
                    _buildRowInfo("Kendaraan", data['kendaraan'] ?? '-'),
                    _buildRowInfo("Jenis Servis", data['jenis_servis'] ?? '-'),
                    _buildRowInfo("Keluhan Awal", data['keluhan'] ?? '-'),
                    
                    const SizedBox(height: 8),
                    // --- Bagian Bawah: Jam Selesai Kerja ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          "Rampung: ${formatTanggal(data['waktu_selesai'] as Timestamp?)}",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ),
          const Text(": ", style: TextStyle(color: Colors.grey, fontSize: 12)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}