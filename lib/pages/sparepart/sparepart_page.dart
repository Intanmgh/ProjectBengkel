import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'tambah_sparepart_page.dart';

class SparepartPage extends StatefulWidget {
  const SparepartPage({super.key});

  @override
  State<SparepartPage> createState() => _SparepartPageState();
}

class _SparepartPageState extends State<SparepartPage> {

  String keyword = "";

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

        // 🔍 SEARCH + BUTTON
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    keyword = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Cari nama atau kode sparepart...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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

        const SizedBox(height: 20),

        // 🔥 TABLE
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

                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nama = (data['nama'] ?? "").toLowerCase();
                  final kode = (data['kode'] ?? "").toLowerCase();
                  return nama.contains(keyword) || kode.contains(keyword);
                }).toList();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: DataTable(
                          border: TableBorder.all(
                            color: Colors.grey.shade400,
                          ),
                          columnSpacing: 25,
                          headingRowHeight: 45,
                          dataRowMinHeight: 70,
                          dataRowMaxHeight: 70,
                          headingRowColor: WidgetStateProperty.all(
                              Colors.grey.shade300),
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),

                          columns: const [
                            DataColumn(label: Text("NO")),
                            DataColumn(label: Text("FOTO")),
                            DataColumn(label: Text("NAMA")),
                            DataColumn(label: Text("KATEGORI")),
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

                            debugPrint("NAMA = ${data['nama']}");
                            debugPrint("FOTO = ${data['foto_url']}");

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
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.image_not_supported);
                                      },
                                    ),
                                  ),
                                ),
                              ),



                              DataCell(Text(data['nama'] ?? "")),

                              DataCell(Text(data['kategori'] ?? "")),

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
                                  "$stok",
                                  style: TextStyle(
                                    color: stok <= minStok
                                        ? Colors.red
                                        : Colors.black,
                                    fontWeight: stok <= minStok
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),

                              DataCell(
                                Text(formatRupiah.format(data['harga_jual'] ?? 0)),
                              ),

                              // 🔥 AKSI (FINAL FIX ADA DI SINI)
                              DataCell(
                                Row(
                                  children: [

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
                                        child: const Icon(Icons.edit,
                                            size: 16, color: Colors.blue),
                                      ),
                                    ),

                                    const SizedBox(width: 6),

                                    // 🗑️ DELETE
                                    GestureDetector(
                                      onTap: () async {
                                        await FirebaseFirestore.instance
                                            .collection('sparepart')
                                            .doc(doc.id)
                                            .delete();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Icon(Icons.delete,
                                            size: 16, color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        )
      ],
    );
  }
}