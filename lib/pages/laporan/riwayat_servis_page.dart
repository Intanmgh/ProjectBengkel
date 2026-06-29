import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'laporan_pdf.dart';

class RiwayatServisPage extends StatefulWidget {
  final VoidCallback onBack;

  const RiwayatServisPage({
    super.key,
    required this.onBack,
  });

  @override
  State<RiwayatServisPage> createState() => _RiwayatServisPageState();
}

class _RiwayatServisPageState extends State<RiwayatServisPage> {
  DateTime? tanggalAwal;
  DateTime? tanggalAkhir;

  final TextEditingController _tanggalAwalController = TextEditingController();
  final TextEditingController _tanggalAkhirController = TextEditingController();

  final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _tanggalAwalController.dispose();
    _tanggalAkhirController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(BuildContext context, bool isAwal) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isAwal) {
          tanggalAwal = picked;
          _tanggalAwalController.text = DateFormat('dd MMMM yyyy').format(picked);
        } else {
          tanggalAkhir = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
          _tanggalAkhirController.text = DateFormat('dd MMMM yyyy').format(picked);
        }
      });
    }
  }

  void _resetFilter() {
    setState(() {
      tanggalAwal = null;
      tanggalAkhir = null;
      _tanggalAwalController.clear();
      _tanggalAkhirController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // HEADER
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 10),
            const Text(
              "Riwayat Servis Pelanggan",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 10),

        const Text(
          "Seluruh riwayat transaksi servis pelanggan, baik yang sudah lunas maupun belum.",
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 20),

        // FILTER
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('invoice').snapshots(),
          builder: (context, snapshot) {
            final allDocs = snapshot.data?.docs ?? [];

            final docsUntukCetak = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final createdAt = data['created_at'];
              if (createdAt == null || createdAt is! Timestamp) return true;
              final tgl = createdAt.toDate();

              if (tanggalAwal != null && tgl.isBefore(tanggalAwal!)) {
                return false;
              }
              if (tanggalAkhir != null && tgl.isAfter(tanggalAkhir!)) {
                return false;
              }
              return true;
            }).toList();

            docsUntukCetak.sort((a, b) {
              final dataA = a.data() as Map<String, dynamic>;
              final dataB = b.data() as Map<String, dynamic>;
              final tglA = (dataA['created_at'] as Timestamp?)?.toDate() ?? DateTime(2000);
              final tglB = (dataB['created_at'] as Timestamp?)?.toDate() ?? DateTime(2000);
              return tglB.compareTo(tglA);
            });

            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tanggalAwalController,
                    readOnly: true,
                    onTap: () => _pilihTanggal(context, true),
                    decoration: InputDecoration(
                      hintText: "Tanggal Awal",
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _tanggalAkhirController,
                    readOnly: true,
                    onTap: () => _pilihTanggal(context, false),
                    decoration: InputDecoration(
                      hintText: "Tanggal Akhir",
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (tanggalAwal != null || tanggalAkhir != null)
                  IconButton(
                    tooltip: "Hapus Filter",
                    onPressed: _resetFilter,
                    icon: const Icon(Icons.clear),
                  ),
                ElevatedButton.icon(
                  onPressed: docsUntukCetak.isEmpty
                      ? null
                      : () {
                          LaporanPdfHelper.cetakRiwayatServis(
                            tanggalAwal: tanggalAwal,
                            tanggalAkhir: tanggalAkhir,
                            rows: docsUntukCetak.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final createdAt = data['created_at'];
                              String tanggalText = '-';
                              if (createdAt is Timestamp) {
                                tanggalText = DateFormat('dd MMMM yyyy')
                                    .format(createdAt.toDate())
                                    .toUpperCase();
                              }
                              final harga = data['total_akhir'];
                              final hargaText = harga is num
                                  ? _rupiahFormat.format(harga)
                                  : 'Rp 0';

                              return {
                                'tanggal': tanggalText,
                                'nama_pelanggan': data['nama_pelanggan'] ?? '-',
                                'kendaraan': data['kendaraan'] ?? '-',
                                'nama_montir': data['nama_montir'] ?? '-',
                                'status': (data['status'] ?? '-').toString(),
                                'total_biaya': hargaText,
                              };
                            }).toList(),
                          );
                        },
                  icon: const Icon(Icons.print),
                  label: const Text("Cetak Laporan PDF"),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        // TABLE
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('invoice')
                  .snapshots(),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Terjadi kesalahan: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final allDocs = snapshot.data?.docs ?? [];

                // Filter tanggal di client side
                final docs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final createdAt = data['created_at'];
                  if (createdAt == null || createdAt is! Timestamp) return true;
                  final tgl = createdAt.toDate();

                  if (tanggalAwal != null && tgl.isBefore(tanggalAwal!)) {
                    return false;
                  }
                  if (tanggalAkhir != null && tgl.isAfter(tanggalAkhir!)) {
                    return false;
                  }
                  return true;
                }).toList();

                // Urutkan terbaru di atas
                docs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final tglA = (dataA['created_at'] as Timestamp?)?.toDate() ?? DateTime(2000);
                  final tglB = (dataB['created_at'] as Timestamp?)?.toDate() ?? DateTime(2000);
                  return tglB.compareTo(tglA);
                });

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada riwayat servis pada rentang ini",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                            ),
                            columnSpacing: 25,
                            headingRowHeight: 50,
                            dataRowMinHeight: 45,
                            dataRowMaxHeight: 55,
                            headingRowColor:
                                WidgetStateProperty.all(Colors.grey.shade200),
                            headingTextStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            columns: const [
                              DataColumn(label: Text("NO")),
                              DataColumn(label: Text("TANGGAL")),
                              DataColumn(label: Text("NAMA PELANGGAN")),
                              DataColumn(label: Text("KENDARAAN")),
                              DataColumn(label: Text("NAMA MONTIR")),
                              DataColumn(label: Text("STATUS")),
                              DataColumn(label: Text("TOTAL BIAYA")),
                            ],
                            rows: List.generate(docs.length, (index) {
                              final data = docs[index].data()
                                  as Map<String, dynamic>;

                              final createdAt = data['created_at'];
                              String tanggalText = '-';
                              if (createdAt is Timestamp) {
                                tanggalText = DateFormat('dd MMMM yyyy')
                                    .format(createdAt.toDate())
                                    .toUpperCase();
                              }

                              final harga = data['total_akhir'];
                              final hargaText = harga is num
                                  ? _rupiahFormat.format(harga)
                                  : 'Rp 0';

                              final status = (data['status'] ?? '-').toString();
                              final badgeColor =
                                  status == 'Lunas' ? Colors.green : Colors.orange;

                              return DataRow(cells: [
                                DataCell(Text("${index + 1}")),
                                DataCell(Text(tanggalText)),
                                DataCell(Text(data['nama_pelanggan'] ?? '-')),
                                DataCell(Text(data['kendaraan'] ?? '-')),
                                DataCell(Text(data['nama_montir'] ?? '-')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: badgeColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(hargaText)),
                              ]);
                            }),
                          ),
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