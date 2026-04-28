import 'package:flutter/material.dart';

class DetailSpkPage extends StatelessWidget {
  final VoidCallback onBack;

  const DetailSpkPage({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xfff5f7fb),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 HEADER
            Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Detail Surat Perintah Kerja (SPK)",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 5),
            const Text(
              "Melihat detail data informasi SPK",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // 🔥 CARD SPK
            Container(
              padding: const EdgeInsets.all(16),
              width: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nomor SPK", style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 5),
                      Text(
                        "SPK - 001",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Proses",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 CONTAINER BESAR
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      sectionTitle(Icons.person, "1. Data Pelanggan & Kendaraan"),

                      table3(
                        ["Nama Pelanggan", "Nomor Telepon", "Email"],
                        ["Farid Shidiq S", "082191811822", "farid@gmail.com"],
                      ),

                      const SizedBox(height: 20),

                      sectionTitle(Icons.description, "DETAIL PEKERJAAN"),

                      table3(
                        ["Jenis Servis", "Nomor Telepon", "Keluhan/Catatan"],
                        ["Service Filter Oli", "082191811822", "Mesin berisik"],
                      ),

                      const SizedBox(height: 20),

                      sectionTitle(Icons.directions_car, "INFORMASI KENDARAAN"),

                      table2(
                        ["Nomor Plat", "Nama Kendaraan"],
                        ["B 3213 CBA", "Mazda 3 HB"],
                      ),

                      const SizedBox(height: 20),

                      sectionTitle(Icons.build, "SPAREPART YANG DIGUNAKAN"),

                      SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columnSpacing: 30,
                          headingRowColor:
                              WidgetStateProperty.all(Colors.blue.shade50),
                          columns: const [
                            DataColumn(label: Text("Nama Sparepart")),
                            DataColumn(label: Text("Kode")),
                            DataColumn(label: Text("Jumlah")),
                            DataColumn(label: Text("Harga")),
                            DataColumn(label: Text("Total")),
                          ],
                          rows: const [
                            DataRow(cells: [
                              DataCell(Text("Filter Oli")),
                              DataCell(Text("MD12301")),
                              DataCell(Text("1")),
                              DataCell(Text("Rp 65.000")),
                              DataCell(Text("Rp 65.000")),
                            ])
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      sectionTitle(Icons.access_time, "DURASI PEKERJAAN"),

                      table4(
                        ["Tanggal Mulai", "Waktu Mulai", "Estimasi Selesai", "Total Durasi"],
                        ["12 Februari 2026", "09:00 WIB", "10:30 WIB", "1 Jam 30 Menit"],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 🔥 SECTION TITLE
  Widget sectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 🔥 TABLE FULL WIDTH + BORDER
  Widget table3(List<String> headers, List<String> values) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnSpacing: 40,
        headingRowColor:
            WidgetStateProperty.all(Colors.blue.shade50),
        columns: headers.map((h) => DataColumn(label: Text(h))).toList(),
        rows: [
          DataRow(
            cells: values.map((v) => DataCell(Text(v))).toList(),
          )
        ],
      ),
    );
  }

  Widget table2(List<String> headers, List<String> values) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnSpacing: 40,
        headingRowColor:
            WidgetStateProperty.all(Colors.blue.shade50),
        columns: headers.map((h) => DataColumn(label: Text(h))).toList(),
        rows: [
          DataRow(
            cells: values.map((v) => DataCell(Text(v))).toList(),
          )
        ],
      ),
    );
  }

  Widget table4(List<String> headers, List<String> values) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnSpacing: 30,
        headingRowColor:
            WidgetStateProperty.all(Colors.blue.shade50),
        columns: headers.map((h) => DataColumn(label: Text(h))).toList(),
        rows: [
          DataRow(
            cells: values.map((v) {
              return DataCell(
                Text(
                  v,
                  style: v.contains("Jam")
                      ? const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold)
                      : null,
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}