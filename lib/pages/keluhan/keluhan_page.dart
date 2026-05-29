import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_keluhan_page.dart';

class KeluhanPage extends StatefulWidget {
  const KeluhanPage({super.key});

  @override
  State<KeluhanPage> createState() => _KeluhanPageState();
}

class _KeluhanPageState extends State<KeluhanPage> {
  bool isDetailKeluhan = false;

  DocumentSnapshot? selectedKeluhan;

  Color statusColor(String status) {
    if (status == "Menunggu") return Colors.orange;
    if (status == "Sedang Proses") return Colors.blue;
    return Colors.green;
  }

  Color statusBg(String status) {
    if (status == "Menunggu") return Colors.orange.shade100;
    if (status == "Sedang Proses") return Colors.blue.shade100;
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
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
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
    if (isDetailKeluhan && selectedKeluhan != null) {
      return DetailKeluhanPage(
        keluhanDoc: selectedKeluhan!,
        onBack: () {
          setState(() {
            isDetailKeluhan = false;
            selectedKeluhan = null;
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Keluhan Pelanggan",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          "Kelola dan pantau seluruh keluhan pelanggan",
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            statCard("Belum Ditangani", "-", Colors.orange),
            const SizedBox(width: 20),
            statCard("Sedang Proses", "-", Colors.blue),
            const SizedBox(width: 20),
            statCard("Selesai", "-", Colors.green),
          ],
        ),

        const SizedBox(height: 20),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('keluhan')
                .orderBy(
                  'created_at',
                  descending: true,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "Belum ada keluhan masuk",
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder.all(
                      color: Colors.grey.shade400,
                    ),
                    columnSpacing: 25,
                    headingRowColor:
                        WidgetStateProperty.all(
                      Colors.grey.shade300,
                    ),
                    columns: const [
                      DataColumn(label: Text("NO")),
                      DataColumn(label: Text("NAMA")),
                      DataColumn(label: Text("EMAIL")),
                      DataColumn(label: Text("JUDUL")),
                      DataColumn(label: Text("STATUS")),
                      DataColumn(label: Text("AKSI")),
                    ],
                    rows: docs.asMap().entries.map(
                      (entry) {
                        int index = entry.key;

                        final doc = entry.value;

                        final data =
                            doc.data() as Map<String, dynamic>;

                        return DataRow(
                          cells: [
                            DataCell(
                              Text("${index + 1}"),
                            ),

                            DataCell(
                              Text(data["nama"] ?? ""),
                            ),

                            DataCell(
                              Text(data["email"] ?? ""),
                            ),

                            DataCell(
                              Text(data["judul"] ?? ""),
                            ),

                            DataCell(
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: statusBg(
                                    data["status"] ??
                                        "Menunggu",
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    6,
                                  ),
                                ),
                                child: Text(
                                  data["status"] ??
                                      "Menunggu",
                                  style: TextStyle(
                                    color: statusColor(
                                      data["status"] ??
                                          "Menunggu",
                                    ),
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            DataCell(
                              ElevatedButton(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.indigo,
                                  foregroundColor:
                                      Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedKeluhan =
                                        doc;
                                    isDetailKeluhan =
                                        true;
                                  });
                                },
                                child:
                                    const Text("Detail"),
                              ),
                            ),
                          ],
                        );
                      },
                    ).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}