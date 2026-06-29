import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryMontirPage extends StatefulWidget {
  final VoidCallback onBack;
  final String namaMontir; // ✅ TAMBAH INI

  const HistoryMontirPage({
    super.key,
    required this.onBack,
    required this.namaMontir, // ✅ TAMBAH INI
  });

  @override
  State<HistoryMontirPage> createState() => _HistoryMontirPageState();
}

class _HistoryMontirPageState extends State<HistoryMontirPage> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  DateTime? selectedDate;

  int currentPage = 1;
  int rowsPerPage = 5;

  // FORMAT BULAN
  String _getMonth(int month) {
    const months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return months[month - 1];
  }

  // FORMAT TANGGAL DARI TIMESTAMP
  String formatTanggal(dynamic createdAt) {
    if (createdAt == null) return "-";
    final date = (createdAt as Timestamp).toDate();
    return "${date.day} ${_getMonth(date.month)} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= HEADER =================
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "History Montir",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Montir: ${widget.namaMontir}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Text("Riwayat SPK selesai yang dikerjakan montir ini"),
          const SizedBox(height: 20),

          // ================= FILTER =================
          Row(
            children: [

              // DATE PICKER
              SizedBox(
                width: 170,
                child: TextField(
                  controller: dateController,
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                        dateController.text =
                            "${pickedDate.day} ${_getMonth(pickedDate.month)} ${pickedDate.year}";
                        currentPage = 1;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Pilih tanggal",
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: selectedDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                selectedDate = null;
                                dateController.clear();
                                currentPage = 1;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 15),

              // SEARCH
              SizedBox(
                width: 250,
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() => currentPage = 1),
                  decoration: const InputDecoration(
                    hintText: "Cari No. SPK atau pelanggan...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ================= TABEL =================
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: StreamBuilder<QuerySnapshot>(
                // ✅ QUERY: ambil SPK milik montir ini yang sudah Selesai
                stream: FirebaseFirestore.instance
                    .collection('spk')
                    .where('nama_montir', isEqualTo: widget.namaMontir)
                    .where('status', isEqualTo: 'Selesai')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final semuaData = snapshot.data!.docs;

                  // ================= FILTER SEARCH & TANGGAL =================
                  final filteredData = semuaData.where((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    final noSpk = (d['no_spk'] ?? doc.id).toString().toLowerCase();
                    final namaPelanggan = (d['nama_pelanggan'] ?? '').toString().toLowerCase();
                    final keyword = searchController.text.toLowerCase();

                    // filter search
                    final matchSearch = noSpk.contains(keyword) ||
                        namaPelanggan.contains(keyword);

                    // filter tanggal
                    bool matchDate = true;
                    if (selectedDate != null && d['created_at'] != null) {
                      final docDate = (d['created_at'] as Timestamp).toDate();
                      matchDate = docDate.year == selectedDate!.year &&
                          docDate.month == selectedDate!.month &&
                          docDate.day == selectedDate!.day;
                    }

                    return matchSearch && matchDate;
                  }).toList();

                  // ================= PAGINATION =================
                  final totalData = filteredData.length;
                  int start = (currentPage - 1) * rowsPerPage;
                  if (start >= totalData && totalData > 0) {
                    start = 0;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() => currentPage = 1);
                    });
                  }
                  final end = (start + rowsPerPage).clamp(0, totalData);
                  final paginatedData = totalData == 0
                      ? <DocumentSnapshot>[]
                      : filteredData.sublist(start, end);

                  return Column(
                    children: [

                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {

                            // EMPTY STATE
                            if (filteredData.isEmpty) {
                              return const Center(
                                child: Text(
                                  "Belum ada riwayat SPK selesai",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

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
                                    headingRowColor: WidgetStateProperty.all(
                                      Colors.grey.shade300,
                                    ),
                                    columns: const [
                                      DataColumn(label: Text("NO")),
                                      DataColumn(label: Text("TANGGAL")),
                                      DataColumn(label: Text("NAMA PELANGGAN")),
                                      DataColumn(label: Text("NO. SPK")),
                                      DataColumn(label: Text("JENIS SERVIS")),
                                      DataColumn(label: Text("STATUS")),
                                    ],
                                    rows: paginatedData.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final doc = entry.value;
                                      final d = doc.data() as Map<String, dynamic>;

                                      final noSpk = d['no_spk'] ?? doc.id;
                                      final tanggal = formatTanggal(d['created_at']);
                                      final jenisServis = d['jenis_servis'] is List
                                          ? (d['jenis_servis'] as List).join(', ')
                                          : (d['jenis_servis'] ?? '-').toString();

                                      return DataRow(cells: [
                                        DataCell(Text("${start + index + 1}")),
                                        DataCell(Text(tanggal)),
                                        DataCell(Text(d['nama_pelanggan'] ?? '-')),
                                        DataCell(
                                          Text(
                                            noSpk,
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(jenisServis)),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              "Selesai",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ================= PAGINATION =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: currentPage > 1
                                ? () => setState(() => currentPage--)
                                : null,
                          ),
                          Text("Halaman $currentPage dari ${((filteredData.length - 1) ~/ rowsPerPage) + 1}"),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: (currentPage * rowsPerPage) < filteredData.length
                                ? () => setState(() => currentPage++)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}