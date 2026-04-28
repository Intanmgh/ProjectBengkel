import 'package:flutter/material.dart';

class HistoryMontirPage extends StatefulWidget {
  final VoidCallback onBack;

  const HistoryMontirPage({super.key, required this.onBack});

  @override
  State<HistoryMontirPage> createState() => _HistoryMontirPageState();
}

class _HistoryMontirPageState extends State<HistoryMontirPage> {

  final TextEditingController searchController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  DateTime? selectedDate;

  int currentPage = 1;
  int rowsPerPage = 5;

  @override
  Widget build(BuildContext context) {

    // 🔥 DATA DUMMY
    List<Map<String, String>> allData = List.generate(20, (index) {
      return {
        "tanggal": "12 Februari 2026",
        "nama": "Farid Shidiq",
        "spk": "SPK-1230$index",
        "spesialis": "Ganti Oli & Filter",
        "status": "Selesai",
      };
    });

    // 🔥 FILTER SEARCH
    final filteredData = allData.where((item) {
      final spk = item['spk']!.toLowerCase();
      return spk.contains(searchController.text.toLowerCase());
    }).toList();

    int totalData = filteredData.length;

    int start = (currentPage - 1) * rowsPerPage;

    if (start >= totalData) {
      start = 0;
      currentPage = 1;
    }

    int end = start + rowsPerPage;
    if (end > totalData) end = totalData;

    final paginatedData =
        totalData == 0 ? [] : filteredData.sublist(start, end);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 🔥 HEADER
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 10),
              const Text(
                "History Montir",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Text("Kelola informasi dan status mekanik bengkel"),

          const SizedBox(height: 20),

          // 🔥 FILTER
          Row(
            children: [

              // 📅 DATE PICKER
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
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Pilih tanggal",
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 15),

              // 🔍 SEARCH
              SizedBox(
                width: 250,
                child: TextField(
                  controller: searchController,
                  onChanged: (_) {
                    setState(() {
                      currentPage = 1;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Cari SPK...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
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
              child: Column(
                children: [

                  Expanded(
                    child: LayoutBuilder(
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
                                  DataColumn(label: Text("TANGGAL")),
                                  DataColumn(label: Text("NAMA PELANGGAN")),
                                  DataColumn(label: Text("NO. SPK")),
                                  DataColumn(label: Text("SPESIALIST")),
                                  DataColumn(label: Text("STATUS")),
                                ],

                                rows: paginatedData.isEmpty
                                    ? []
                                    : paginatedData.asMap().entries.map((entry) {
                                        int index = entry.key;
                                        var d = entry.value;

                                        return DataRow(cells: [
                                          DataCell(Text("${start + index + 1}")),
                                          DataCell(Text(d['tanggal']!)),
                                          DataCell(Text(d['nama']!)),
                                          DataCell(
                                            Text(
                                              d['spk']!,
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(d['spesialis']!)),

                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
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

                  // 🔥 PAGINATION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: currentPage > 1
                            ? () => setState(() => currentPage--)
                            : null,
                      ),
                      Text("Halaman $currentPage"),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: (currentPage * rowsPerPage) < filteredData.length
                            ? () => setState(() => currentPage++)
                            : null,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 FORMAT BULAN
  String _getMonth(int month) {
    const months = [
      "Januari","Februari","Maret","April","Mei","Juni",
      "Juli","Agustus","September","Oktober","November","Desember"
    ];
    return months[month - 1];
  }
}