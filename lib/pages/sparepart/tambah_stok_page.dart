import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Dialog khusus untuk MENAMBAH STOK (restock) sparepart yang sudah ada.
///
/// Beda dengan TambahSparepartPage (yang isi field "stok" = nilai akhir),
/// dialog ini hanya minta JUMLAH BARANG MASUK, lalu otomatis dijumlahkan
/// ke stok lama pakai FieldValue.increment() — jadi tidak perlu hitung
/// manual dan aman walau ada beberapa input bersamaan.
class TambahStokPage extends StatefulWidget {
  final String docId;
  final String namaSparepart;
  final int stokSaatIni;

  const TambahStokPage({
    super.key,
    required this.docId,
    required this.namaSparepart,
    required this.stokSaatIni,
  });

  @override
  State<TambahStokPage> createState() => _TambahStokPageState();
}

class _TambahStokPageState extends State<TambahStokPage> {
  final jumlahController = TextEditingController();
  bool isLoading = false;

  int get jumlahTambah => int.tryParse(jumlahController.text) ?? 0;
  int get stokSetelah => widget.stokSaatIni + jumlahTambah;

  @override
  void dispose() {
    jumlahController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    final jumlah = jumlahTambah;

    if (jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Jumlah stok masuk harus lebih dari 0"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('sparepart')
          .doc(widget.docId)
          .update({
        'stok': FieldValue.increment(jumlah),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Stok berhasil ditambah $jumlah pcs"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tambah Stok",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            Text(
              widget.namaSparepart,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 20),

            // STOK SAAT INI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Stok saat ini", style: TextStyle(color: Colors.grey)),
                  Text(
                    "${widget.stokSaatIni}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // INPUT JUMLAH MASUK
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Jumlah Stok Masuk",
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                    TextSpan(text: "  *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Contoh: 20",
                helperText: "Jumlah barang baru yang masuk, bukan total akhir",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 12),

            // PREVIEW STOK SETELAH DITAMBAH
            if (jumlahTambah > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Stok setelah ditambah", style: TextStyle(color: Colors.green)),
                    Text(
                      "$stokSetelah",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 25),

            // TOMBOL
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isLoading ? null : _simpan,
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.add_circle_outline),
                    label: Text(isLoading ? "Menyimpan..." : "Tambah Stok"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}