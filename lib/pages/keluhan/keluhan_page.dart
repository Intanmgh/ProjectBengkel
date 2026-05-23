import 'package:flutter/material.dart';
import 'detail_keluhan_page.dart'; // 🔥 TAMBAHAN

class KeluhanPage extends StatefulWidget {
  const KeluhanPage({super.key});

  @override
  State<KeluhanPage> createState() => _KeluhanPageState();
}

class _KeluhanPageState extends State<KeluhanPage> {

  bool isDetailKeluhan = false; // 🔥 TAMBAHAN

  List<Map<String, String>> allData = [
    {
      "tanggal": "12 Februari 2026",
      "nama": "Farid Shidiq S",
      "plat": "B 1245 ACB",
      "keluhan": "Bunyi cit cit di dalam mesin",
      "status": "Menunggu"
    },
    {
      "tanggal": "10 Februari 2026",
      "nama": "Farid Shidiq S",
      "plat": "B 1245 ACB",
      "keluhan": "Mesin terasa berat saat dinyalakan",
      "status": "Selesai"
    },
    {
      "tanggal": "09 Februari 2026",
      "nama": "Farid Shidiq S",
      "plat": "B 1245 ACB",
      "keluhan": "Getaran berlebih saat idle",
      "status": "Proses"
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
      return data["nama"]!
              .toLowerCase()
              .contains(keyword.toLowerCase()) ||
          data["plat"]!
              .toLowerCase()
              .contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      filteredData = results;
    });
  }

  Color statusColor(String status) {
    if (status == "Menunggu") return Colors.orange;
    if (status == "Proses") return Colors.blue;
    return Colors.green;
  }

  Color statusBg(String status) {
    if (status == "Menunggu") return Colors.orange.shade100;
    if (status == "Proses") return Colors.blue.shade100;
    return Colors.green.shade100;
  }

  Widget statCard(String title, String value, Color color) {
    IconData icon;

    if (title.contains("Belum")) {
      icon = Icons.schedule;
    } else if (title.contains("Proses")) {
      icon = Icons.settings;
    } else {
      icon = Icons.check_circle;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // 🔥 HALAMAN DETAIL
    if (isDetailKeluhan) {
      return DetailKeluhanPage(
        onBack: () {
          setState(() {
            isDetailKeluhan = false;
          });
        },
      );
    }

    // 🔥 HALAMAN UTAMA
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Keluhan Pelanggan",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),
        const Text("Kelola dan pantau seluruh keluhan pelanggan"),

        const SizedBox(height: 20),

        Row(
          children: [
            statCard("Belum Ditangani", "10", Colors.orange),
            const SizedBox(width: 20),
            statCard("Sedang Proses", "8", Colors.blue),
            const SizedBox(width: 20),
            statCard("Selesai", "20", Colors.green),
          ],
        ),

        const SizedBox(height: 20),

        TextField(
          onChanged: searchData,
          decoration: InputDecoration(
            hintText: "Cari nama pelanggan atau nomor polisi...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        const SizedBox(height: 20),

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
                      border: TableBorder.all(color: Colors.grey.shade400),
                      columnSpacing: 25,
                      headingRowColor:
                          WidgetStateProperty.all(Colors.grey.shade300),
                      columns: const [
                        DataColumn(label: Text("NO")),
                        DataColumn(label: Text("TANGGAL")),
                        DataColumn(label: Text("NAMA")),
                        DataColumn(label: Text("NO. PLAT")),
                        DataColumn(label: Text("KELUHAN")),
                        DataColumn(label: Text("STATUS")),
                        DataColumn(label: Text("AKSI")),
                      ],
                      rows: filteredData.asMap().entries.map((entry) {
                        int index = entry.key;
                        var data = entry.value;

                        return DataRow(cells: [
                          DataCell(Text("${index + 1}")),
                          DataCell(Text(data["tanggal"]!)),
                          DataCell(Text(data["nama"]!)),
                          DataCell(Text(data["plat"]!)),
                          DataCell(Text(data["keluhan"]!)),

                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBg(data["status"]!),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                data["status"]!,
                                style: TextStyle(
                                  color: statusColor(data["status"]!),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // 🔥 FIX DETAIL BUTTON
                          DataCell(
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  isDetailKeluhan = true;
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