import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'tambah_sparepart_page.dart';
import 'tambah_stok_page.dart';

class _WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class SparepartPage extends StatefulWidget {
  const SparepartPage({super.key});

  @override
  State<SparepartPage> createState() => _SparepartPageState();
}

class _SparepartPageState extends State<SparepartPage> {
  String keyword = "";
  String filterKategori = "Semua";
  String filterStok = "Semua";

  final formatRupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Data Sparepart",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text("Kelola informasi dan status barang sparepart"),
        const SizedBox(height: 20),

        // ================= SEARCH + BUTTON =================
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => keyword = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: "Cari nama atau kode sparepart...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const TambahSparepartPage(),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Tambah Sparepart"),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ================= FILTER =================
        Row(
          children: [
            const Icon(Icons.filter_list, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            const Text("Filter:", style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(width: 10),

            // Filter Kategori
            _buildFilterDropdown(
              value: filterKategori,
              items: const ["Semua", "Oli", "Grease" ,"Filter Oli", "Filter Udara","Filter AC", "Filter Bahan Bakar", "Kampas Rem",
                            "Pompa", "Additive", "Spare Part",],
              onChanged: (val) => setState(() => filterKategori = val!),
            ),

            const SizedBox(width: 10),

            // Filter Stok
            _buildFilterDropdown(
              value: filterStok,
              items: const ["Semua", "Stok Normal", "Stok Menipis", "Stok Habis"],
              onChanged: (val) => setState(() => filterStok = val!),
            ),

            const SizedBox(width: 10),

            // Tombol reset
            if (filterKategori != "Semua" || filterStok != "Semua" || keyword.isNotEmpty)
              TextButton.icon(
                onPressed: () => setState(() {
                  filterKategori = "Semua";
                  filterStok = "Semua";
                  keyword = "";
                }),
                icon: const Icon(Icons.close, size: 14, color: Colors.red),
                label: const Text("Reset", style: TextStyle(color: Colors.red, fontSize: 13)),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // ================= TABLE =================
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sparepart')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // ===== APPLY FILTER =====
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nama = (data['nama'] ?? "").toLowerCase();
                  final kode = (data['kode'] ?? "").toLowerCase();
                  final kategori = data['kategori'] ?? "";
                  final stok = data['stok'] ?? 0;
                  final minStok = data['min_stok'] ?? 0;

                  final cocokKeyword = nama.contains(keyword) || kode.contains(keyword);
                  final cocokKategori = filterKategori == "Semua" || kategori == filterKategori;

                  bool cocokStok = true;
                  if (filterStok == "Stok Normal") cocokStok = stok > minStok;
                  if (filterStok == "Stok Menipis") cocokStok = stok > 0 && stok <= minStok;
                  if (filterStok == "Stok Habis") cocokStok = stok == 0;

                  return cocokKeyword && cocokKategori && cocokStok;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text(
                          "Tidak ada data yang cocok",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () => setState(() {
                            filterKategori = "Semua";
                            filterStok = "Semua";
                            keyword = "";
                          }),
                          child: const Text("Reset Filter"),
                        ),
                      ],
                    ),
                  );
                }

                return ScrollConfiguration(
                  behavior: _WebScrollBehavior(),
                  child: Scrollbar(
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ScrollConfiguration(
                        behavior: _WebScrollBehavior(),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SizedBox(
                            width: 1400,
                            child: DataTable(
                              border: TableBorder.all(color: Colors.grey.shade400),
                              columnSpacing: 35,
                              headingRowHeight: 45,
                              dataRowMinHeight: 70,
                              dataRowMaxHeight: 70,
                              headingRowColor: WidgetStateProperty.all(Colors.grey.shade300),
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              columns: const [
                                DataColumn(label: Text("NO")),
                                DataColumn(label: Text("FOTO")),
                                DataColumn(label: Text("NAMA")),
                                DataColumn(label: Text("KATEGORI")),
                                DataColumn(label: Text("TYPE KENDARAAN")),
                                DataColumn(label: Text("KODE")),
                                DataColumn(label: Text("STOK")),
                                DataColumn(label: Text("HARGA JUAL")),
                                DataColumn(label: Text("AKSI")),
                              ],
                              rows: filtered.asMap().entries.map((entry) {
                                int index = entry.key;
                                var doc = entry.value;
                                final data = doc.data() as Map<String, dynamic>;

                                int stok = data['stok'] ?? 0;
                                int minStok = data['min_stok'] ?? 0;

                                // warna stok
                                Color stokColor = Colors.black;
                                FontWeight stokWeight = FontWeight.normal;
                                String stokLabel = "$stok";
                                if (stok == 0) {
                                  stokColor = Colors.red;
                                  stokWeight = FontWeight.bold;
                                  stokLabel = "0 (Habis)";
                                } else if (stok <= minStok) {
                                  stokColor = Colors.orange;
                                  stokWeight = FontWeight.bold;
                                  stokLabel = "$stok (Menipis)";
                                }

                                return DataRow(
                                  cells: [

                                    DataCell(Text("${index + 1}")),

                                    DataCell(
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.network(
                                            data['foto_url'] ?? '',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.image_not_supported, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ),

                                    DataCell(Text(data['nama'] ?? "")),
                                    DataCell(Text(data['kategori'] ?? "")),

                                    DataCell(
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          data['type_kendaraan'] ?? "-",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),

                                    DataCell(
                                      Text(
                                        data['kode'] ?? "",
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    DataCell(
                                      Text(
                                        stokLabel,
                                        style: TextStyle(
                                          color: stokColor,
                                          fontWeight: stokWeight,
                                        ),
                                      ),
                                    ),

                                    DataCell(
                                      Text(formatRupiah.format(data['harga_jual'] ?? 0)),
                                    ),

                                    DataCell(
                                      Row(
                                        children: [

                                          // 📦 TAMBAH STOK
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => TambahStokPage(
                                                  docId: doc.id,
                                                  namaSparepart: data['nama'] ?? '-',
                                                  stokSaatIni: data['stok'] ?? 0,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Icon(Icons.add_box, size: 16, color: Colors.green),
                                            ),
                                          ),

                                          const SizedBox(width: 6),

                                          // ✏️ EDIT
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => TambahSparepartPage(
                                                  docId: doc.id,
                                                  data: data,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                                            ),
                                          ),

                                          const SizedBox(width: 6),

                                          // 🗑 DELETE
                                          GestureDetector(
                                            onTap: () async {
                                              final konfirmasi = await showDialog<bool>(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: const Text("Hapus Sparepart"),
                                                  content: Text(
                                                    "Yakin ingin menghapus \"${data['nama']}\"?",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, false),
                                                      child: const Text("Batal"),
                                                    ),
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red,
                                                        foregroundColor: Colors.white,
                                                      ),
                                                      onPressed: () => Navigator.pop(context, true),
                                                      child: const Text("Hapus"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (konfirmasi == true) {
                                                await FirebaseFirestore.instance
                                                    .collection('sparepart')
                                                    .doc(doc.id)
                                                    .delete();
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Icon(Icons.delete, size: 16, color: Colors.red),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

      ],
    );
  }

  // ================= HELPER FILTER DROPDOWN =================
  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final isActive = value != "Semua";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.blue : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          style: TextStyle(
            fontSize: 13,
            color: isActive ? Colors.blue.shade700 : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: isActive ? Colors.blue : Colors.grey,
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}