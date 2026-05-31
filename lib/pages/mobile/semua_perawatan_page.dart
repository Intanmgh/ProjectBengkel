import 'package:flutter/material.dart';
import 'detail_perawatan_page.dart';

class SemuaPerawatanPage extends StatelessWidget {
  final List<Map<String, dynamic>> daftarLayanan;

  const SemuaPerawatanPage({super.key, required this.daftarLayanan});

  @override
  Widget build(BuildContext context) {
    // Kita filter agar menu "Keluhan" dan "Lainnya" tidak ikut muncul di daftar perawatan
    final listPerawatan = daftarLayanan.where((layanan) => 
      layanan["title"] != "Keluhan" && layanan["title"] != "Lainnya"
    ).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Semua Perawatan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: listPerawatan.length,
        itemBuilder: (context, index) {
          final item = listPerawatan[index];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item["icon"], color: Colors.blue.shade800, size: 26),
              ),
              title: Text(
                item["title"],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0), // Gunakan .only dengan parameter top
                child: Text(
                  "Harga: ${item["harga"]}\nEstimasi: ${item["estimasi"]}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              isThreeLine: true,
              onTap: () {
                // Ketika item diklik, langsung oper data ke halaman detail
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPerawatanPage(dataLayanan: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}