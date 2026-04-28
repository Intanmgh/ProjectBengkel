import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tambah_montir_page.dart';


class MontirPage extends StatefulWidget {
  final VoidCallback onHistoryClick;

  const MontirPage({super.key, required this.onHistoryClick});

  @override
  State<MontirPage> createState() => _MontirPageState();
}

class _MontirPageState extends State<MontirPage> {

  // WARNA STATUS
  Color statusColor(String status) {
    if (status == "Aktif") return Colors.green;
    if (status == "Libur") return Colors.orange;
    return Colors.red;
  }

  Color statusBg(String status) {
    if (status == "Aktif") return Colors.green.shade100;
    if (status == "Libur") return Colors.orange.shade100;
    return Colors.red.shade100;
  }

  // HAPUS DATA
  Future<void> hapusData(String id) async {
    await FirebaseFirestore.instance
        .collection('montir')
        .doc(id)
        .delete();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data montir dihapus")),
    );
  }

  // INPUT (UNTUK EDIT)
  Widget buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // EDIT DATA
  void editData(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final nama = TextEditingController(text: data['nama']);
    final telp = TextEditingController(text: data['telp']);
    final spesialis = TextEditingController(text: data['spesialis']);

    String selectedStatus = data['status'] ?? "Aktif";

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Edit Data Montir",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close),
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    buildInput("Nama Lengkap Montir *", nama),
                    buildInput("Nomor Telepon *", telp),
                    buildInput("Spesialisasi *", spesialis),

                    // STATUS
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Status Montir *"),
                          const SizedBox(height: 5),
                          DropdownButtonFormField<String>(
                            initialValue: selectedStatus,
                            items: ["Aktif", "Libur", "Tidak Aktif"]
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedStatus = value!;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text("Batal"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final navigator = Navigator.of(dialogContext);

                            await FirebaseFirestore.instance
                                .collection('montir')
                                .doc(doc.id)
                                .update({
                              'nama': nama.text,
                              'telp': telp.text,
                              'spesialis': spesialis.text,
                              'status': selectedStatus,
                            });

                            if (!mounted) return;

                            navigator.pop();
                          },
                          icon: const Icon(Icons.save),
                          label: const Text("Update"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text("Data Montir",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari montir...",
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
                  builder: (_) => const TambahMontirPage(),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text("Tambah Montir"),
            ),
          ],
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('montir')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!.docs;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            border: TableBorder.all(
                              color: Colors.grey.shade400,
                            ),
                            columnSpacing: 25,
                            headingRowColor:
                                WidgetStateProperty.all(Colors.grey.shade300),

                            columns: const [
                              DataColumn(label: Text("NO")),
                              DataColumn(label: Text("NAMA MONTIR")),
                              DataColumn(label: Text("SPESIALISASI")),
                              DataColumn(label: Text("NOMOR TELEPON")),
                              DataColumn(label: Text("STATUS")),
                              DataColumn(label: Text("AKSI")),
                            ],

                            rows: data.asMap().entries.map((entry) {
                              int index = entry.key;
                              var doc = entry.value;
                              final d = doc.data() as Map<String, dynamic>;

                              return DataRow(cells: [
                                DataCell(Text("${index + 1}")),
                                DataCell(Text(d['nama'] ?? '')),
                                DataCell(Text(d['spesialis'] ?? '')),
                                DataCell(Text(d['telp'] ?? '')),

                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusBg(d['status']),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      d['status'] ?? '',
                                      style: TextStyle(
                                        color: statusColor(d['status']),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => editData(doc),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => hapusData(doc.id),
                                      ),

                                      // 🔥 HISTORY (SUDAH ADA)
                                      Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: InkWell(
                                            onTap: widget.onHistoryClick,
                                            borderRadius: BorderRadius.circular(6),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2E7D32), // 🔥 hijau solid
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Icon(Icons.history, size: 16, color: Colors.white), // putih
                                                  SizedBox(width: 5),
                                                  Text(
                                                    "History",
                                                    style: TextStyle(
                                                      color: Colors.white, // putih
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
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
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}