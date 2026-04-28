import 'package:flutter/material.dart';
import 'tambah_servis_page.dart';
import 'detail_servis_page.dart'; // 🔥 TAMBAHAN

class ServisPage extends StatefulWidget {
  const ServisPage({super.key});

  @override
  State<ServisPage> createState() => _ServisPageState();
}

class _ServisPageState extends State<ServisPage> {

  bool isTambahServis = false;
  bool isDetailServis = false; // 🔥 TAMBAHAN

  List<Map<String, String>> allData = [
    {
      "invoice": "INVOICE-123244",
      "nama": "Farid Shidiq S",
      "montir": "Farid Shidiq S",
      "plat": "B 1245 ACB",
      "kendaraan": "Mazda 3 Hashback"
    },
    {
      "invoice": "INVOICE-123245",
      "nama": "Budi Santoso",
      "montir": "Bambang",
      "plat": "B 2222 XYZ",
      "kendaraan": "Avanza"
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
      return data["invoice"]!
              .toLowerCase()
              .contains(keyword.toLowerCase()) ||
          data["nama"]!
              .toLowerCase()
              .contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      filteredData = results;
    });
  }

  @override
  Widget build(BuildContext context) {

    // 🔥 HALAMAN TAMBAH SERVIS
    if (isTambahServis) {
      return TambahServisPage(
        onBack: () {
          setState(() {
            isTambahServis = false;
          });
        },
      );
    }

    // 🔥 HALAMAN DETAIL SERVIS
    if (isDetailServis) {
      return DetailServisPage(
        onBack: () {
          setState(() {
            isDetailServis = false;
          });
        },
      );
    }

    // 🔥 HALAMAN UTAMA
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pencatatan Data Servis",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),
        const Text(
            "Pembuatan data administrasi biaya servis dan tambahkan sparepart"),

        const SizedBox(height: 20),

        // 🔍 SEARCH + BUTTON
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: searchData,
                decoration: InputDecoration(
                  hintText: "Cari nama pelanggan atau invoice...",
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
                setState(() {
                  isTambahServis = true;
                });
              },
              icon: const Icon(Icons.person_add),
              label: const Text("Tambah Invoice Baru"),
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
                        DataColumn(label: Text("INVOICE")),
                        DataColumn(label: Text("NAMA PELANGGAN")),
                        DataColumn(label: Text("NAMA MONTIR")),
                        DataColumn(label: Text("NO. PLAT")),
                        DataColumn(label: Text("NAMA KENDARAAN")),
                        DataColumn(label: Text("AKSI")),
                      ],
                      rows: filteredData.asMap().entries.map((entry) {
                        int index = entry.key;
                        var data = entry.value;

                        return DataRow(cells: [
                          DataCell(Text("${index + 1}")),
                          DataCell(
                            Text(
                              data["invoice"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Text(data["nama"]!)),
                          DataCell(Text(data["montir"]!)),
                          DataCell(Text(data["plat"]!)),
                          DataCell(Text(data["kendaraan"]!)),

                          // 🔥 FIX DETAIL BUTTON
                          DataCell(
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 8),
                                textStyle:
                                    const TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                setState(() {
                                  isDetailServis = true;
                                });
                              },
                              child: const Text("Detail"),
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