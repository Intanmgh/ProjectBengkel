import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'tambah_servis_page.dart';
import 'detail_servis_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServisPage extends StatefulWidget {
  const ServisPage({super.key});

  @override
  State<ServisPage> createState() => _ServisPageState();
}

class _ServisPageState extends State<ServisPage> {

  bool isTambahServis = false;
  bool isDetailServis = false;

  Map<String, dynamic>? selectedSpk;

  final TextEditingController searchController = TextEditingController();

  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (isTambahServis && selectedSpk != null) {
      return TambahServisPage(
        spkData: selectedSpk!,
        onBack: () {
          setState(() {
            isTambahServis = false;
          });
        },
      );
    }

    if (isDetailServis) {
      return DetailServisPage(
        spkId: selectedSpk?['id'] ?? '',
        onBack: () {
          setState(() {
            isDetailServis = false;
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Pencatatan Data Servis",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        const Text(
          "Pembuatan data administrasi biaya servis dan tambahkan sparepart",
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Cari nama pelanggan, no SPK, atau montir...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('spk')
                .where('status', isEqualTo: 'Selesai')
                .snapshots(), // 🔥 orderBy dihapus dari query, sort dikerjakan di bawah
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("Belum ada SPK yang selesai"),
                );
              }

              final keyword = searchController.text.toLowerCase();

              // 🔥 FILTER + SORT TERBARU DI ATAS (client-side)
              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final nama = (data['nama_pelanggan'] ?? '').toString().toLowerCase();
                final noSpk = (data['no_spk'] ?? '').toString().toLowerCase();
                final montir = (data['nama_montir'] ?? '').toString().toLowerCase();
                final plat = (data['plat'] ?? '').toString().toLowerCase();
                return nama.contains(keyword) ||
                    noSpk.contains(keyword) ||
                    montir.contains(keyword) ||
                    plat.contains(keyword);
              }).toList()
                ..sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;

                    final aSudah = aData['status_invoice'] ?? false;
                    final bSudah = bData['status_invoice'] ?? false;

                    // 🔥 PRIORITAS 1: belum invoice di atas, sudah invoice di bawah
                    if (aSudah != bSudah) {
                      return aSudah ? 1 : -1;
                    }

                    // 🔥 PRIORITAS 2: dalam grup yang sama, terbaru di atas
                    final aTime = aData['created_at'] as Timestamp?;
                    final bTime = bData['created_at'] as Timestamp?;
                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;
                    return bTime.compareTo(aTime);
                  });

              if (docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Center(
                    child: Text(
                      "Data tidak ditemukan",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Listener(
                      onPointerSignal: (event) {
                        if (event is PointerScrollEvent) {
                          if (event.scrollDelta.dx != 0) {
                            final newOffset = (_horizontalController.offset +
                                    event.scrollDelta.dx)
                                .clamp(
                              0.0,
                              _horizontalController.position.maxScrollExtent,
                            );
                            _horizontalController.jumpTo(newOffset);
                          } else {
                            final newOffset = (_verticalController.offset +
                                    event.scrollDelta.dy)
                                .clamp(
                              0.0,
                              _verticalController.position.maxScrollExtent,
                            );
                            _verticalController.jumpTo(newOffset);
                          }
                        }
                      },
                      child: Scrollbar(
                        controller: _verticalController,
                        thumbVisibility: true,
                        child: Scrollbar(
                          controller: _horizontalController,
                          thumbVisibility: true,
                          notificationPredicate: (notif) => notif.depth == 1,
                          child: SingleChildScrollView(
                            controller: _verticalController,
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              controller: _horizontalController,
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: DataTable(
                                  border: TableBorder.all(
                                    color: Colors.grey.shade400,
                                  ),
                                  columnSpacing: 30,
                                  headingRowHeight: 48,
                                  dataRowMinHeight: 55,
                                  dataRowMaxHeight: 65,
                                  headingRowColor: WidgetStateProperty.all(
                                    Colors.grey.shade300,
                                  ),
                                  headingTextStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  columns: const [
                                    DataColumn(label: Text("NO")),
                                    DataColumn(label: Text("NO SPK")),
                                    DataColumn(label: Text("NAMA PELANGGAN")),
                                    DataColumn(label: Text("NAMA MONTIR")),
                                    DataColumn(label: Text("PLAT")),
                                    DataColumn(label: Text("KENDARAAN")),
                                    DataColumn(label: Text("STATUS INVOICE")),
                                    DataColumn(label: Text("AKSI")),
                                  ],
                                  rows: docs.asMap().entries.map((entry) {

                                    final index = entry.key;
                                    final doc = entry.value;
                                    final data = doc.data() as Map<String, dynamic>;
                                    final sudahInvoice = data['status_invoice'] ?? false;

                                    return DataRow(cells: [

                                      DataCell(Text("${index + 1}")),

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
                                      DataCell(Text(data['plat'] ?? '-')),
                                      DataCell(Text(data['kendaraan'] ?? '-')),

                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: sudahInvoice
                                                ? Colors.green.shade100
                                                : Colors.orange.shade100,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            sudahInvoice ? "Sudah Dibuat" : "Belum Dibuat",
                                            style: TextStyle(
                                              color: sudahInvoice
                                                  ? Colors.green
                                                  : Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: sudahInvoice
                                                ? Colors.indigo
                                                : Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            selectedSpk = {
                                              ...data,
                                              'id': doc.id,
                                            };
                                            setState(() {
                                              if (sudahInvoice) {
                                                isDetailServis = true;
                                              } else {
                                                isTambahServis = true;
                                              }
                                            });
                                          },
                                          child: Text(
                                            sudahInvoice ? "Detail" : "Buat Invoice",
                                          ),
                                        ),
                                      ),
                                    ]);
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
              );
            },
          ),
        ),
      ],
    );
  }
}