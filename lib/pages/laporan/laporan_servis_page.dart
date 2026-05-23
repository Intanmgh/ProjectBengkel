import 'package:flutter/material.dart';

class LaporanServisPage extends StatelessWidget {
  final VoidCallback onBack;

  const LaporanServisPage({
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
              "Laporan Servis & Transaksi",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 🔥 CARD STATISTIK
        Row(
          children: [
            statCard("Total Transaksi", "15", Icons.people, Colors.blue),
            const SizedBox(width: 20),
            statCard("Pendapatan", "Rp 2.320.000", Icons.attach_money, Colors.green),
            const SizedBox(width: 20),
            statCard("Kendaraan", "12", Icons.directions_car, Colors.orange),
          ],
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
              label: const Text("Cetak PDF"),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 🔥 TABLE (SUDAH DI UPGRADE)
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
                      minWidth: constraints.maxWidth, // 🔥 FULL LEBAR
                    ),
                    child: DataTable(
                      border: TableBorder.all(
                        color: Colors.grey.shade300, // 🔥 GARIS
                        width: 1,
                      ),
                      columnSpacing: 30,
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
                        DataColumn(label: Text("NO. SPK")),
                        DataColumn(label: Text("NAMA PELANGGAN")),
                        DataColumn(label: Text("NAMA MONTIR")),
                        DataColumn(label: Text("KENDARAAN")),
                        DataColumn(label: Text("TOTAL BIAYA")),
                      ],

                      rows: List.generate(5, (index) {
                        return DataRow(cells: [
                          DataCell(Text("${index + 1}")),
                          const DataCell(Text("12 FEBRUARI 2026")),
                          const DataCell(
                            Text(
                              "SPK - 001",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const DataCell(Text("Farid Shidiq S")),
                          const DataCell(Text("Farid Shidiq S")),
                          const DataCell(Text("Mazda 3 HB")),
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

  Widget statCard(String title, String value, IconData icon, Color color) {
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
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}