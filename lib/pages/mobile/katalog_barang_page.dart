import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class KatalogBarangPage extends StatefulWidget {
  const KatalogBarangPage({super.key});

  @override
  State<KatalogBarangPage> createState() => _KatalogBarangPageState();
}

class _KatalogBarangPageState extends State<KatalogBarangPage> {
  String _searchQuery = "";
  String _selectedKategori = "Semua";

  // List kategori disesuaikan dengan dropdown milik admin + pilihan "Semua"
  final List<String> kategoriList = ["Semua", "Oli", "Filter", "Kampas"];

  // Format Rupiah bawaan agar tampilan harga rapi seperti di admin
  final formatRupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Logika gambar aset lokal mobile kamu
  String _getGambarKategori(String kategori) {
    switch (kategori) {
      case "Oli":
        return "assets/shell_yellow.png"; 
      case "Filter":
        return "assets/shell_yellow.png";    
      case "Kampas":
        return "assets/shell_yellow.png"; 
      default:
        return "assets/shell_yellow.png"; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Katalog Barang",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Produk Sparepart",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // ================= SEARCH & FILTER BAR =================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    // Input Pencarian Multi-Kriteria (Nama & Kategori)
                    Expanded(
                      flex: 3,
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "Cari nama atau kategori...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ),
                    // Dropdown Filter Kategori
                    Expanded(
                      flex: 2,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          value: _selectedKategori,
                          isExpanded: true,
                          alignment: Alignment.centerRight,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                          decoration: const InputDecoration(border: InputBorder.none),
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                          items: kategoriList.map((String kat) {
                            return DropdownMenuItem<String>(
                              value: kat,
                              child: Text(kat, textAlign: TextAlign.right),
                            );
                          }).toList(),
                          onChanged: (String? newVal) {
                            setState(() {
                              _selectedKategori = newVal ?? "Semua";
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= NETWORKING REAL-TIME DARI ADMIN =================
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('sparepart').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("Belum ada data barang dari admin", style: TextStyle(color: Colors.grey)),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    // 🔥 PERBAIKAN UTAMA: Mengubah logika penyaringan di memori lokal HP
                    final listProdukTerfilter = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      
                      // Tarik data nama dan kategori dari Firestore, lalu ubah ke huruf kecil
                      final String nama = (data['nama'] ?? "").toString().toLowerCase();
                      final String kategori = (data['kategori'] ?? "").toString().toLowerCase();

                      // Logika Dropdown Filter Atas
                      final cocokDropdownKategori = _selectedKategori == "Semua" || 
                          kategori == _selectedKategori.toLowerCase();
                          
                      // 🔥 LOGIKA BARU: Kolom ketik bisa membaca kecocokan pada Nama ATAU Kategori
                      final cocokKetikSearch = nama.contains(_searchQuery) || 
                          kategori.contains(_searchQuery);

                      return cocokDropdownKategori && cocokKetikSearch;
                    }).toList();

                    if (listProdukTerfilter.isEmpty) {
                      return const Center(
                        child: Text("Produk tidak ditemukan", style: TextStyle(color: Colors.grey)),
                      );
                    }

                    // ================= GRID TAMPILAN 2 KOLOM BORDER BIRU =================
                    return GridView.builder(
                      itemCount: listProdukTerfilter.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final data = listProdukTerfilter[index].data() as Map<String, dynamic>;
                        
                        String kategoriBarang = data['kategori'] ?? "Oli";
                        String namaBarang = data['nama'] ?? "-";
                        int hargaJual = data['harga_jual'] ?? 0;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue.shade700, width: 1.5),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Menampilkan gambar pintar berdasarkan kategori data admin
                              Expanded(
                                child: Image.asset(
                                  _getGambarKategori(kategoriBarang),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.build_circle, size: 60, color: Colors.blue.shade300);
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Nama Barang asli inputan admin
                              Text(
                                namaBarang,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Harga Jual asli inputan admin (sudah diformat Rp)
                              Text(
                                formatRupiah.format(hargaJual),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}