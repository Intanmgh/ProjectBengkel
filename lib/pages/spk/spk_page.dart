import 'package:flutter/material.dart';
import 'tambah_spk_page.dart';

class SpkPage extends StatefulWidget {
  const SpkPage({super.key});

  @override
 State<SpkPage> createState() => _SpkPageState();
}

class _SpkPageState extends State<SpkPage> {
  List<Map<String, String>> allData = [
    {
      "tanggal": "12 FEBRUARI 2026",
      "spk": "SPK-001",
      "nama": "Farid Shidiq S",
      "plat": "B 1245 ACB",
      "kendaraan": "Mazda 3 Hashback",
      "montir": "Farid Shidiq S",
      "status": "Menunggu"
    },
    {
      "tanggal": "12 FEBRUARI 2026",
      "spk": "SPK-002",
      "nama": "Farid Shidiq S",
      "plat": "B 1245 ACB",
      "kendaraan": "Mazda 3 Hashback",
      "montir": "Farid Shidiq S",
      "status": "Selesai"
    },
    {
      "tanggal": "12 FEBRUARI 2026",
      "spk": "SPK-003",
      "nama": "Farid Shidiq S",
      "plat": "B 1245 ACB",
      "kendaraan": "Mazda 3 Hashback",
      "montir": "Farid Shidiq S",
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
      return data["spk"]!.toLowerCase().contains(keyword.toLowerCase()) ||
          data["nama"]!.toLowerCase().contains(keyword.toLowerCase());
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

 Widget statCard(String title, String value, Color color, IconData icon) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // 🔥 ICON (INI YANG KAMU MAU)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Data Surat Perintah Kerja (SPK)",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),
        const Text("Kelola dan pantau seluruh Surat Perintah Kerja bengkel"),

        const SizedBox(height: 20),

        // 🔥 CARD STATISTIK
        Row(
        children: [
          statCard("Semua SPK", "24", Colors.purple, Icons.description),
          const SizedBox(width: 20),
          statCard("Menunggu", "15 SPK", Colors.orange, Icons.schedule),
          const SizedBox(width: 20),
          statCard("Proses", "10 SPK", Colors.blue, Icons.build),
          const SizedBox(width: 20),
          statCard("Selesai", "5 SPK", Colors.green, Icons.check_circle),
        ],
      ),

        const SizedBox(height: 20),

        // 🔍 SEARCH + BUTTON
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: searchData,
                decoration: InputDecoration(
                  hintText: "Cari No. SPK atau pelanggan...",
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TambahSpkPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Tambah SPK"),
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
                      border: TableBorder.all(color: Colors.grey.shade400),
                      columnSpacing: 25,
                      headingRowColor:
                          WidgetStateProperty.all(Colors.grey.shade300),
                      columns: const [
                        DataColumn(label: Text("TANGGAL")),
                        DataColumn(label: Text("NO SPK")),
                        DataColumn(label: Text("NAMA")),
                        DataColumn(label: Text("PLAT")),
                        DataColumn(label: Text("KENDARAAN")),
                        DataColumn(label: Text("MONTIR")),
                        DataColumn(label: Text("STATUS")),
                        DataColumn(label: Text("AKSI")),
                      ],
                      rows: filteredData.map((data) {
                        return DataRow(cells: [
                          DataCell(Text(data["tanggal"]!)),
                          DataCell(
                            Text(
                              data["spk"]!,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataCell(Text(data["nama"]!)),
                          DataCell(Text(data["plat"]!)),
                          DataCell(Text(data["kendaraan"]!)),
                          DataCell(Text(data["montir"]!)),

                          // STATUS
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

                          // AKSI
                          DataCell(
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white, // 🔥 langsung global ke text & icon
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () {},
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