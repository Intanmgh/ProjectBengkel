import 'package:flutter/material.dart';
import 'tambah_sparepart_page.dart';

class SparepartPage extends StatefulWidget {
  const SparepartPage({super.key});

  @override
  State<SparepartPage> createState() => _SparepartPageState();
}

class _SparepartPageState extends State<SparepartPage> {
  List<Map<String, String>> allData = [
    {
      "nama": "Filter Oli",
      "kode": "MD120345",
      "stok": "45",
      "harga": "Rp. 100.000"
    },
    {
      "nama": "Busi Iridium",
      "kode": "MD120346",
      "stok": "1",
      "harga": "Rp. 85.000"
    },
    {
      "nama": "V-Belt",
      "kode": "MD120347",
      "stok": "3",
      "harga": "Rp. 186.000"
    },
  ];

  List<Map<String, String>> filteredData = [];

  @override
  void initState() {
    super.initState();
    filteredData = allData;
  }

  void searchData(String keyword) {
    final results = allData.where((data) {
      final nama = data["nama"]!.toLowerCase();
      final kode = data["kode"]!.toLowerCase();
      return nama.contains(keyword.toLowerCase()) ||
          kode.contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      filteredData = results;
    });
  }

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
                onChanged: searchData,
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      border: TableBorder.all(
                        color: Colors.grey.shade400,
                      ),
                      columnSpacing: 25,
                      headingRowHeight: 45,
                      dataRowMinHeight: 45,
                      dataRowMaxHeight: 55,
                      headingRowColor: WidgetStateProperty.all(
                          Colors.grey.shade300),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      columns: const [
                        DataColumn(label: Text("NO")),
                        DataColumn(label: Text("NAMA SPAREPART")),
                        DataColumn(label: Text("KODE PART")),
                        DataColumn(label: Text("STOK")),
                        DataColumn(label: Text("HARGA JUAL")),
                        DataColumn(label: Text("AKSI")),
                      ],
                      rows: filteredData.asMap().entries.map((entry) {
                        int index = entry.key;
                        var data = entry.value;

                        return DataRow(cells: [
                          DataCell(Text("${index + 1}")),
                          DataCell(Text(data["nama"]!)),
                          DataCell(
                            Text(
                              data["kode"]!,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Text(data["stok"]!)),
                          DataCell(Text(data["harga"]!)),

                          // 🔥 AKSI
                          DataCell(
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.edit,
                                      size: 16, color: Colors.blue),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.delete,
                                      size: 16, color: Colors.red),
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
            ),
          ),
        )
      ],
    );
  }
}