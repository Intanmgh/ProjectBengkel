import 'package:flutter/material.dart';
import 'laporan_servis_page.dart'; // 🔥 IMPORT
import 'riwayat_servis_page.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {

  bool isLaporanServis = false; // 🔥 STATE
  bool isRiwayatServis = false;

  Widget laporanCard({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required VoidCallback onTap, // 🔥 TAMBAHAN
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white),
            ),

            const SizedBox(height: 15),

            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              desc,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: onTap, // 🔥 DIPAKAI
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Buka Laporan"),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // 🔥 HALAMAN DETAIL LAPORAN
    if (isLaporanServis) {
      return LaporanServisPage(
        onBack: () {
          setState(() {
            isLaporanServis = false;
          });
        },
      );
    }

    if (isRiwayatServis) {
      return RiwayatServisPage(
        onBack: () {
          setState(() {
            isRiwayatServis = false;
          });
        },
      );
    }

    // 🔥 HALAMAN UTAMA
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Laporan & Riwayat",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),
        const Text("Pilih jenis data yang ingin anda akses atau kelola hari ini"),

        const SizedBox(height: 30),

        Row(
          children: [
            laporanCard(
              icon: Icons.build,
              color: Colors.orange,
              title: "Laporan Servis & Transaksi",
              desc:
                  "Rekapitulasi pekerjaan mekanik, estimasi waktu, dan status pengerjaan kendaraan",
              onTap: () {
                setState(() {
                  isLaporanServis = true; // 🔥 MASUK HALAMAN
                });
              },
            ),

            const SizedBox(width: 20),

            laporanCard(
              icon: Icons.description,
              color: Colors.green,
              title: "Riwayat Servis Pelanggan",
              desc:
                  "Pencarian data historis berdasarkan plat nomor atau nama pemilik kendaraan",
              onTap: () {
                setState(() {
                  isRiwayatServis = true;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}