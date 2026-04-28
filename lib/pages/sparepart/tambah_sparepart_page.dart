import 'package:flutter/material.dart';

class TambahSparepartPage extends StatelessWidget {
  const TambahSparepartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 800, // 🔥 lebih lebar karena 2 kolom
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔥 HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tambah Data Sparepart Baru",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                )
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 FORM 2 KOLOM
            Row(
              children: [
                // KIRI
                Expanded(
                  child: Column(
                    children: [
                      buildInput("Nama Sparepart *", "Contoh: Filter Oli"),
                      buildInput("Kode Part / SKU", "MD102456"),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // KANAN
                Expanded(
                  child: Column(
                    children: [
                      buildInput("Harga Beli", "Rp 0"),
                      buildInput("Stok Awal", "0", suffix: "Pcs"),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // KANAN 2
                Expanded(
                  child: Column(
                    children: [
                      buildInput("Harga Jual", "Rp 0"),
                      buildInput("Minimal Stok", "0", suffix: "Pcs"),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 🔥 BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 220,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Simpan Data"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildInput(String label, String hint, {String? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 5),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              suffixText: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}