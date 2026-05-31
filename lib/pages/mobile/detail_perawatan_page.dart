import 'package:flutter/material.dart';

class DetailPerawatanPage extends StatelessWidget {
  final Map<String, dynamic> dataLayanan;

  const DetailPerawatanPage({super.key, required this.dataLayanan});

  @override
  Widget build(BuildContext context) {
    // Mengambil daftar "Apa Saja yang Dikerjakan" dari data yang dikirim
    final List<String> pekerjaan = dataLayanan["pekerjaan"] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          dataLayanan["title"] ?? "Detail Perawatan",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GAMBAR ILLUSTRASI UTAMA
            Container(
              width: double.infinity,
              height: 220,
              color: Colors.grey.shade100,
              child: Image.asset(
                dataLayanan["image"] ?? 'assets/tuneup_placeholder.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Jika file gambar belum ada di assets, otomatis pakai icon biar tidak error
                  return Icon(dataLayanan["icon"], size: 80, color: Colors.blue.shade800);
                },
              ),
            ),

            // 2. DESKRIPSI PENJELASAN
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                dataLayanan["deskripsi"] ?? "Penjelasan mengenai layanan perawatan.",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            
            const Divider(height: 1, thickness: 1),

            // 3. INFORMASI ESTIMASI, BIAYA, GARANSI, INTERVAL (Sesuai Gambar)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow(Icons.access_time_filled, "Estimasi: ${dataLayanan["estimasi"]}"),
                  _buildInfoRow(Icons.verified, "Garansi: ${dataLayanan["garansi"]}"),
                  _buildInfoRow(Icons.thumb_up, "Interval: ${dataLayanan["interval"]}"),
                  _buildInfoRow(Icons.account_balance_wallet_rounded, "Harga: ${dataLayanan["harga"]}"),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // 4. BAGIAN "APA SAJA YANG DIKERJAKAN?"
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bagian \"Apa Saja yang Dikerjakan?\"",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Me-render list pekerjaan secara dinamis
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pekerjaan.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                pekerjaan[index],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat baris informasi dengan background bulat abu-abu tipis (seperti di gambar)
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}