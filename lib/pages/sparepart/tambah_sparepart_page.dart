// import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';

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
  final fotoController = TextEditingController();



  String selectedKategori = "Oli";
  final kategoriList = ["Oli", "Filter", "Kampas"];

  // Uint8List? _imageBytes;
  // String? _existingImageUrl;
  // bool isUploadingImage = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
  namaController.text = widget.data!['nama'] ?? '';
  beliController.text = (widget.data!['harga_beli'] ?? 0).toString();
  jualController.text = (widget.data!['harga_jual'] ?? 0).toString();
  stokController.text = (widget.data!['stok'] ?? 0).toString();
  minStokController.text = (widget.data!['min_stok'] ?? 0).toString();
  fotoController.text = widget.data!['foto_url'] ?? '';
  selectedKategori = widget.data!['kategori'] ?? "Oli";
}
  }

  // ================= PILIH GAMBAR =================
  // Future<void> pilihGambar() async {
  //   final picker = ImagePicker();
  //   final picked = await picker.pickImage(
  //     source: ImageSource.gallery,
  //     maxWidth: 800,
  //     maxHeight: 800,
  //     imageQuality: 80,
  //   );

  //   if (picked != null) {
  //     final bytes = await picked.readAsBytes();
  //     setState(() {
  //       _imageBytes = bytes;
  //     });
  //   }
  // }

  // ================= UPLOAD GAMBAR =================
  // Future<String?> uploadGambar(String kode) async {
  //   if (_imageBytes == null) return _existingImageUrl;

  //   setState(() => isUploadingImage = true);

  //   try {
  //     final ref = FirebaseStorage.instance
  //         .ref()
  //         .child('sparepart')
  //         .child('$kode.jpg');

  //     await ref.putData(
  //       _imageBytes!,
  //       SettableMetadata(contentType: 'image/jpeg'),
  //     );

  //     final url = await ref.getDownloadURL();
  //     setState(() => isUploadingImage = false);
  //     return url;

  //   } catch (e) {
  //     setState(() => isUploadingImage = false);
  //     if (!mounted) return null;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Gagal upload gambar: $e")),
  //     );
  //     return null;
  //   }
  // }

  // ================= GENERATE KODE (CEPAT - PAKAI TIMESTAMP) =================
//   String getDefaultFoto(String kategori) {
//   switch (kategori) {
//     case "Oli":
//       return "assets/images/oli.jpeg";

//     case "Filter":
//       return "assets/images/filter.jpeg";

//     case "Kampas":
//       return "assets/images/kampas.jpeg";

//     default:
//       return "assets/images/logo.png";
//   }
// }

Future<String> generateKode(String kategori) async {
  Map<String, String> prefixMap = {
    "Oli": "OLI",
    "Filter": "FIL",
    "Kampas": "KPS",
  };

  String prefix = prefixMap[kategori] ?? "SPR";

  final snapshot = await FirebaseFirestore.instance
      .collection('sparepart')
      .where('kategori', isEqualTo: kategori)
      .get();

  int nomorTerakhir = 0;

  for (var doc in snapshot.docs) {
    final kode = doc['kode'] ?? '';

    if (kode.toString().startsWith(prefix)) {
      try {
        final nomor =
            int.parse(kode.toString().split('-').last);

        if (nomor > nomorTerakhir) {
          nomorTerakhir = nomor;
        }
      } catch (_) {}
    }
  }

  final nomorBaru = nomorTerakhir + 1;

  return "$prefix-${nomorBaru.toString().padLeft(4, '0')}";
}

  // ================= SIMPAN DATA =================
  Future<void> simpanData() async {

    final nama = namaController.text.trim();
    final kategori = selectedKategori;
    final hargaBeli = int.tryParse(beliController.text) ?? 0;
    final hargaJual = int.tryParse(jualController.text) ?? 0;
    final stok = int.tryParse(stokController.text) ?? 0;
    final minStok = int.tryParse(minStokController.text) ?? 0;

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama sparepart wajib diisi")),
      );
      return;
    }

    if (fotoController.text.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Link foto wajib diisi"),
    ),
  );
  return;
}

    setState(() => isLoading = true);

    try {

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
          'foto_url': fotoController.text.trim(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data berhasil diupdate"),
            backgroundColor: Colors.green,
          ),
        );

      } else {

        // ✅ TAMBAH - kode langsung dari timestamp, tidak perlu query Firestore
        final kode = await generateKode(kategori);

        await FirebaseFirestore.instance.collection('sparepart').add({
          'nama': nama,
          'kategori': kategori,
          'kode': kode,
          'harga_beli': hargaBeli,
          'harga_jual': hargaJual,
          'stok': stok,
          'min_stok': minStok,
          'foto_url': fotoController.text.trim(),
          'created_at': Timestamp.now(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data berhasil ditambahkan"),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 900,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ================= HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.docId == null
                      ? "Tambah Data Sparepart"
                      : "Edit Data Sparepart",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ================= KOLOM KIRI =================
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
                          setState(() => selectedKategori = value!);
                        },
                        decoration: InputDecoration(
                          labelText: "Kategori",
                          helperText: "Pilih jenis sparepart",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      buildInput("Stok", stokController),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // ================= KOLOM TENGAH =================
                Expanded(
                  child: Column(
                    children: [
                      buildInput("Harga Beli", beliController),
                      buildInput("Harga Jual", jualController),
                      buildInput("Minimal Stok", minStokController),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // ================= KOLOM KANAN - FOTO =================
                Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      TextField(
        controller: fotoController,
        onChanged: (_) {
          setState(() {});
        },
        decoration: InputDecoration(
          labelText: "Link Foto",
          hintText: "https://...",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      const SizedBox(height: 15),

      Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: fotoController.text.trim().isEmpty
            ? const Center(
                child: Text("Preview gambar"),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  fotoController.text.trim(),
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        "Link gambar tidak valid",
                      ),
                    );
                  },
                ),
              ),
      ),
    ],
  ),
),

 ],
            ),


            const SizedBox(height: 25),

            // ================= TOMBOL =================
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
                    onPressed: isLoading ? null : simpanData,
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      isLoading
                          ? "Menyimpan..."
                          : "Simpan Data",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= BUILD INPUT =================
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
    } else if (label.contains("Minimal")) {
      hint = "Contoh: 5";
      helper = "Batas minimum stok";
    } else if (label.contains("Stok")) {
      hint = "Contoh: 10";
      helper = "Jumlah barang tersedia";
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