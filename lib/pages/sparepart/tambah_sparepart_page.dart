import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahSparepartPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;

  const TambahSparepartPage({
    super.key,
    this.docId,
    this.data,
  });

  @override
  State<TambahSparepartPage> createState() => _TambahSparepartPageState();
}

class _TambahSparepartPageState extends State<TambahSparepartPage> {

  final namaController = TextEditingController();
  final beliController = TextEditingController();
  final jualController = TextEditingController();
  final stokController = TextEditingController();
  final minStokController = TextEditingController();

  String selectedKategori = "Oli";

  final kategoriList = ["Oli", "Filter", "Kampas"];

  @override
  void initState() {
    super.initState();

    // 🔥 FIX: HANDLE NULL BIAR GA JADI "null"
    if (widget.data != null) {
      namaController.text = widget.data!['nama'] ?? '';
      beliController.text = (widget.data!['harga_beli'] ?? 0).toString();
      jualController.text = (widget.data!['harga_jual'] ?? 0).toString();
      stokController.text = (widget.data!['stok'] ?? 0).toString();
      minStokController.text = (widget.data!['min_stok'] ?? 0).toString();
      selectedKategori = widget.data!['kategori'] ?? "Oli";
    }
  }

  // 🔥 GENERATE KODE
  Future<String> generateKode(String kategori) async {

    Map<String, String> prefixMap = {
      "Oli": "OLI",
      "Filter": "FIL",
      "Kampas": "KPS",
    };

    String prefix = prefixMap[kategori]!;

    final snapshot = await FirebaseFirestore.instance
        .collection('sparepart')
        .where('kategori', isEqualTo: kategori)
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return "$prefix-0001";
    }

    String lastKode = snapshot.docs.first['kode'];
    int number = int.parse(lastKode.split('-')[1]);
    number++;

    return "$prefix-${number.toString().padLeft(4, '0')}";
  }

  // 🔥 SIMPAN DATA FINAL
  Future<void> simpanData() async {
    try {

      final nama = namaController.text.trim();
      final kategori = selectedKategori;

      final hargaBeli = int.tryParse(beliController.text) ?? 0;
      final hargaJual = int.tryParse(jualController.text) ?? 0;
      final stok = int.tryParse(stokController.text) ?? 0;
      final minStok = int.tryParse(minStokController.text) ?? 0;

      // 🔥 VALIDASI SEDERHANA
      if (nama.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nama sparepart wajib diisi")),
        );
        return;
      }

      // ✅ EDIT
      if (widget.docId != null) {

        await FirebaseFirestore.instance
            .collection('sparepart')
            .doc(widget.docId)
            .update({
          'nama': nama,
          'kategori': kategori,
          'harga_beli': hargaBeli,
          'harga_jual': hargaJual,
          'stok': stok,
          'min_stok': minStok,
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diupdate")),
        );

      } else {

        // ✅ TAMBAH
        String kode = await generateKode(kategori);

        await FirebaseFirestore.instance.collection('sparepart').add({
          'nama': nama,
          'kategori': kategori,
          'kode': kode,
          'harga_beli': hargaBeli,
          'harga_jual': hargaJual,
          'stok': stok,
          'min_stok': minStok,
          'created_at': Timestamp.now(),
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil ditambahkan")),
        );
      }

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
        width: 800,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.docId == null
                      ? "Tambah Data Sparepart"
                      : "Edit Data Sparepart",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                )
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: Column(
                    children: [

                      buildInput("Nama Sparepart *", namaController),

                     DropdownButtonFormField<String>(
                      initialValue: selectedKategori,
                      items: kategoriList.map((k) {
                        return DropdownMenuItem(
                          value: k,
                          child: Text(k),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedKategori = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Kategori",
                        helperText: "Pilih jenis sparepart",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                      const SizedBox(height: 10),

                      buildInput("Stok", stokController),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    children: [
                      buildInput("Harga Beli", beliController),
                      buildInput("Harga Jual", jualController),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    children: [
                      buildInput("Minimal Stok", minStokController),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
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
                    ),
                    onPressed: simpanData,
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

 Widget buildInput(String label, TextEditingController controller) {
  String hint = "";
  String helper = "";

  if (label.contains("Nama")) {
    hint = "Contoh: Oli Shell Helix";
    helper = "Isi nama sparepart sesuai produk";
  } else if (label.contains("Harga Beli")) {
    hint = "Contoh: 50000";
    helper = "Tanpa Rp atau titik";
  } else if (label.contains("Harga Jual")) {
    hint = "Contoh: 75000";
    helper = "Harga jual ke pelanggan";
  } else if (label.contains("Stok")) {
    hint = "Contoh: 10";
    helper = "Jumlah barang tersedia";
  } else if (label.contains("Minimal")) {
    hint = "Contoh: 5";
    helper = "Batas minimum stok";
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helper,
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