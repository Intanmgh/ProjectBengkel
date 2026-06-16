import 'package:flutter/material.dart';

class DetailSpkPage extends StatelessWidget {
  final VoidCallback onBack;
  final Map<String, dynamic> spkData; // ← TAMBAHAN

  const DetailSpkPage({
    super.key,
    required this.onBack,
    required this.spkData, // ← TAMBAHAN
  });

  // ================= FORMAT RUPIAH =================

  String formatRupiah(dynamic angka) {
    if (angka == null) return "Rp 0";
    final number = int.parse(angka.toString());
    return "Rp ${number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}";
  }

  // ================= WARNA STATUS =================

  Color statusColor(String status) {
    if (status == "Menunggu") return Colors.orange;
    if (status == "Proses") return Colors.blue;
    return Colors.green;
  }

  Color statusBg(String status) {
    if (status == "Menunggu") return Colors.orange.shade50;
    if (status == "Proses") return Colors.blue.shade50;
    return Colors.green.shade50;
  }

  @override
  Widget build(BuildContext context) {

    // ================= AMBIL DATA =================
    final noSpk = spkData['noSpk'] ?? '-';
    final tanggal = spkData['tanggal'] ?? '-';
    final status = spkData['status'] ?? 'Menunggu';

    final namaPelanggan = spkData['nama_pelanggan'] ?? '-';
    final plat = spkData['plat'] ?? '-';
    final kendaraan = spkData['kendaraan'] ?? '-';
    final km = spkData['km']?.toString() ?? '-';

    final keluhan = spkData['keluhan'] ?? '-';
    final jenisServis =
    spkData['jenis_servis'] is List
        ? (spkData['jenis_servis'] as List).join(', ')
        : (spkData['jenis_servis'] ?? '-').toString();

    final namaMontir = spkData['nama_montir'] ?? '-';

    final waktu = spkData['waktu'] ?? '-';
    final estimasi = spkData['estimasi'] ?? '-';

    final totalHarga = spkData['total_harga'] ?? 0;

    final List<dynamic> spareparts = spkData['sparepart'] ?? [];

    return Material(
      color: const Color(0xfff5f7fb),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= HEADER =================
            Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Detail Surat Perintah Kerja (SPK)",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            const Text(
              "Melihat detail data informasi SPK",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // ================= CARD NOMOR SPK =================
            Container(
              padding: const EdgeInsets.all(16),
              width: 400,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Nomor SPK",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        noSpk,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tanggal,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg(status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= CONTAINER DETAIL =================
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

                      // ================= DATA PELANGGAN =================
                      sectionTitle(
                        Icons.person,
                        "1. Data Pelanggan & Kendaraan",
                      ),

                      tableData(
                        headers: ["Nama Pelanggan", "No. Plat", "Kendaraan", "KM Terakhir"],
                        values: [namaPelanggan, plat, kendaraan, km],
                      ),

                      const SizedBox(height: 20),

                      // ================= DETAIL PEKERJAAN =================
                      sectionTitle(
                        Icons.description,
                        "2. Detail Pekerjaan",
                      ),

                      tableData(
                        headers: ["Jenis Servis", "Keluhan / Catatan"],
                        values: [jenisServis, keluhan],
                      ),

                      const SizedBox(height: 20),

                      // ================= MONTIR =================
                      sectionTitle(
                        Icons.engineering,
                        "3. Montir Bertugas",
                      ),

                      tableData(
                        headers: ["Nama Montir"],
                        values: [namaMontir],
                      ),

                      const SizedBox(height: 20),

                      // ================= SPAREPART =================
                      sectionTitle(
                        Icons.build,
                        "4. Sparepart Yang Digunakan",
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          border: TableBorder.all(
                            color: Colors.grey.shade300,
                          ),
                          columnSpacing: 30,
                          headingRowColor: WidgetStateProperty.all(
                            Colors.blue.shade50,
                          ),
                          columns: const [
                            DataColumn(label: Text("Nama Sparepart")),
                            DataColumn(label: Text("Kode")),
                            DataColumn(label: Text("Jumlah")),
                            DataColumn(label: Text("Harga Satuan")),
                            DataColumn(label: Text("Subtotal")),
                          ],
                          rows: spareparts.isEmpty
                              ? [
                                  const DataRow(cells: [
                                    DataCell(Text("-")),
                                    DataCell(Text("-")),
                                    DataCell(Text("-")),
                                    DataCell(Text("-")),
                                    DataCell(Text("-")),
                                  ])
                                ]
                              : spareparts.map((item) {
                                  final harga = int.parse(
                                    item['harga_jual_saat_itu'].toString(),
                                  );
                                  final jumlah = item['jumlah'] as int;
                                  final subtotal = harga * jumlah;

                                  return DataRow(cells: [
                                    DataCell(Text(item['nama'] ?? '-')),
                                    DataCell(Text(item['kode'] ?? '-')),
                                    DataCell(Text("$jumlah")),
                                    DataCell(Text(formatRupiah(harga))),
                                    DataCell(Text(formatRupiah(subtotal))),
                                  ]);
                                }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= WAKTU =================
                      sectionTitle(
                        Icons.access_time,
                        "5. Durasi Pekerjaan",
                      ),

                      tableData(
                        headers: [
                          "Tanggal Mulai",
                          "Waktu Mulai",
                          "Estimasi Pengerjaan",
                        ],
                        values: [tanggal, waktu, estimasi],
                      ),

                      const SizedBox(height: 20),

                      // ================= TOTAL HARGA =================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade800,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Biaya Sparepart",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              formatRupiah(totalHarga),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SECTION TITLE =================

  Widget sectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= TABLE DATA =================

  Widget tableData({
    required List<String> headers,
    required List<String> values,
  }) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnSpacing: 40,
        headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
        columns: headers
            .map((h) => DataColumn(label: Text(h)))
            .toList(),
        rows: [
          DataRow(
            cells: values
                .map((v) => DataCell(Text(v)))
                .toList(),
          ),
        ],
      ),
    );
  }
}