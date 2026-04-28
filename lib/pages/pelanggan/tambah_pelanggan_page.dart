import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahPelangganPage extends StatefulWidget {
  const TambahPelangganPage({super.key});

  @override
  State<TambahPelangganPage> createState() => _TambahPelangganPageState();
}

class _TambahPelangganPageState extends State<TambahPelangganPage> {

  final namaController = TextEditingController();
  final telpController = TextEditingController();
  final platController = TextEditingController();
  final kendaraanController = TextEditingController();
  final kmController = TextEditingController();

  Future<void> simpanData() async {
    try {
      await FirebaseFirestore.instance.collection('pelanggan').add({
        'nama': namaController.text.trim(),
        'telepon': telpController.text.trim(),
        'plat': platController.text.trim(),
        'kendaraan': kendaraanController.text.trim(),
        'km': kmController.text.trim(),
        'created_at': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil disimpan")),
      );

      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tambah Pelanggan Baru",
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

            buildInput("Nama Lengkap *", "Masukkan nama lengkap pelanggan", namaController),
            buildInput("Nomor Telepon *", "+62 812345678", telpController),
            buildInput("Nomor Plat *", "B 1234 ABC", platController),
            buildInput("Nama Kendaraan *", "Avanza / Xpander", kendaraanController),
            buildInput("KM Terakhir *", "24.000 KM", kmController),

            const SizedBox(height: 20),

            // BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: simpanData,
                  icon: const Icon(Icons.save),
                  label: const Text("Simpan"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildInput(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
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