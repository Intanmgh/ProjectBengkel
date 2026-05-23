import 'package:flutter/material.dart';

class RiwayatServisPage extends StatelessWidget {
  final VoidCallback onBack;

  const RiwayatServisPage({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
              "Riwayat Servis Pelanggan",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 10),

        const Text(
          "Masukkan nama pelanggan atau nomor plat kendaraan untuk melihat detail riwayat pemeliharaan berkala.",
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 20),

        // 🔥 FILTER
        Row(
          children: [
            Expanded(
              child: TextField(
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

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print),
              label: const Text("Cetak Laporan PDF"),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 🔥 TABLE
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
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
                        DataColumn(label: Text("TANGGAL MULAI")),
                        DataColumn(label: Text("JENIS SERVIS")),
                        DataColumn(label: Text("NAMA PELANGGAN")),
                        DataColumn(label: Text("NAMA MONTIR")),
                        DataColumn(label: Text("TOTAL BIAYA AKHIR")),
                      ],

                      rows: List.generate(5, (index) {
                        return DataRow(cells: [
                          DataCell(Text("${index + 1}")),
                          const DataCell(Text("12 FEBRUARI 2026")),
                          const DataCell(Text("Tune Up Mesin")),
                          const DataCell(Text("Farid Shidiq S")),
                          const DataCell(Text("Farid Shidiq S")),
                          const DataCell(Text("Rp 1.456.000")),
                        ]);
                      }),
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