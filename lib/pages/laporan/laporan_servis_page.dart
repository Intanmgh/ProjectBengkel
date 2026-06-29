import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'laporan_pdf.dart';

class LaporanServisPage extends StatefulWidget {
  final VoidCallback onBack;

  const LaporanServisPage({
    super.key,
    required this.onBack,
  });

  @override
  State<LaporanServisPage> createState() => _LaporanServisPageState();
}

class _LaporanServisPageState extends State<LaporanServisPage> {
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
          // set ke akhir hari supaya tanggal akhir ikut terhitung
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
              "Laporan Servis & Transaksi",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // STREAM DATA INVOICE (status = Lunas)
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('invoice')
                .where('status', isEqualTo: 'Lunas')
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

              // Ambil semua data lunas, lalu filter tanggal di client side
              final allDocs = snapshot.data?.docs ?? [];

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

              // HITUNG STATISTIK
              int totalTransaksi = docs.length;
              double totalPendapatan = 0;
              final Set<String> platUnik = {};

              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final harga = data['total_akhir'];
                if (harga is num) {
                  totalPendapatan += harga.toDouble();
                }
                final plat = data['plat'];
                if (plat != null && plat.toString().isNotEmpty) {
                  platUnik.add(plat.toString());
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // CARD STATISTIK
                  Row(
                    children: [
                      statCard("Total Transaksi", totalTransaksi.toString(),
                          Icons.receipt_long, Colors.blue),
                      const SizedBox(width: 20),
                      statCard("Pendapatan", _rupiahFormat.format(totalPendapatan),
                          Icons.attach_money, Colors.green),
                      const SizedBox(width: 20),
                      statCard("Kendaraan", platUnik.length.toString(),
                          Icons.directions_car, Colors.orange),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // FILTER
                  Row(
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
                        onPressed: docs.isEmpty
                            ? null
                            : () {
                                LaporanPdfHelper.cetakLaporanServis(
                                  tanggalAwal: tanggalAwal,
                                  tanggalAkhir: tanggalAkhir,
                                  rows: docs.map((doc) {
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
                                      'no_spk': data['no_spk'] ?? '-',
                                      'nama_pelanggan': data['nama_pelanggan'] ?? '-',
                                      'nama_montir': data['nama_montir'] ?? '-',
                                      'kendaraan': data['kendaraan'] ?? '-',
                                      'total_biaya': hargaText,
                                    };
                                  }).toList(),
                                );
                              },
                        icon: const Icon(Icons.print),
                        label: const Text("Cetak PDF"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // TABEL
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: docs.isEmpty
                          ? const Center(
                              child: Text(
                                "Belum ada transaksi lunas pada rentang ini",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : LayoutBuilder(
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
                                          width: 1,
                                        ),
                                        columnSpacing: 30,
                                        headingRowHeight: 50,
                                        dataRowMinHeight: 45,
                                        dataRowMaxHeight: 55,
                                        headingRowColor: WidgetStateProperty.all(
                                            Colors.grey.shade200),
                                        headingTextStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        columns: const [
                                          DataColumn(label: Text("NO")),
                                          DataColumn(label: Text("TANGGAL")),
                                          DataColumn(label: Text("NO. SPK")),
                                          DataColumn(label: Text("NAMA PELANGGAN")),
                                          DataColumn(label: Text("NAMA MONTIR")),
                                          DataColumn(label: Text("KENDARAAN")),
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

                                          return DataRow(cells: [
                                            DataCell(Text("${index + 1}")),
                                            DataCell(Text(tanggalText)),
                                            DataCell(
                                              Text(
                                                data['no_spk'] ?? '-',
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            DataCell(Text(data['nama_pelanggan'] ?? '-')),
                                            DataCell(Text(data['nama_montir'] ?? '-')),
                                            DataCell(Text(data['kendaraan'] ?? '-')),
                                            DataCell(Text(hargaText)),
                                          ]);
                                        }),
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
            },
          ),
        ),
      ],
    );
  }

  Widget statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
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
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}