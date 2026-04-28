import 'package:flutter/material.dart';

class TambahSpkPage extends StatelessWidget {
  const TambahSpkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Buat Surat Perintah Kerja (SPK)",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("Lengkapi formulir dibawah untuk mendaftarkan antrian servis"),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ===================== 1 =====================
                  sectionTitle(Icons.person, "1. Data Pelanggan & Kendaraan"),

                  label("Cari Pelanggan / No. Plat"),
                  input("Ketik nama atau plat nomor"),

                  const SizedBox(height: 15),

                  DataTable(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columns: const [
                      DataColumn(label: Text("Nama Pelanggan")),
                      DataColumn(label: Text("No. Plat")),
                      DataColumn(label: Text("Kendaraan")),
                      DataColumn(label: Text("KM Terakhir")),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Text("Farid Shidiq S")),
                        DataCell(Text("B 12346 CB")),
                        DataCell(Text("Mazda 3 HB")),
                        DataCell(Text("24.000")),
                      ])
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ===================== 2 =====================
                  sectionTitle(Icons.description, "2. Keluhan & Jenis Servis"),

                  label("Detail Keluhan"),
                  input("Jelaskan masalah...", maxLines: 3),

                  const SizedBox(height: 10),

                  label("Jenis Servis"),
                  dropdown("Pilih Jenis Servis"),

                  const SizedBox(height: 25),

                  // ===================== 3 =====================
                  sectionTitle(Icons.engineering, "3. Pilih Montir"),

                  label("Montir Yang Bertugas"),
                  dropdown("Pilih Montir"),

                  const SizedBox(height: 25),

                  // ===================== 4 =====================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      sectionTitle(Icons.build, "4. Pilih Sparepart"),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, color: Colors.blue),
                        label: const Text("Tambah item"),
                      )
                    ],
                  ),

                  input("Cari nama sparepart/code"),

                  const SizedBox(height: 10),

                  DataTable(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columns: const [
                      DataColumn(label: Text("Nama Sparepart")),
                      DataColumn(label: Text("Kode")),
                      DataColumn(label: Text("Jumlah")),
                      DataColumn(label: Text("Harga")),
                      DataColumn(label: Text("Aksi")),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text("Filter Oli")),
                        const DataCell(Text("MD12301")),
                        const DataCell(Text("1")),
                        const DataCell(Text("Rp. 65.000")),
                        DataCell(
                          Icon(Icons.delete, color: Colors.red),
                        ),
                      ])
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ===================== 5 =====================
                  sectionTitle(Icons.access_time, "5. Pilih Waktu"),

                  Row(
                    children: [
                      Expanded(child: input("Tanggal")),
                      const SizedBox(width: 10),
                      Expanded(child: input("Waktu")),
                      const SizedBox(width: 10),
                      Expanded(child: dropdown("Durasi")),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "1 Jam 30 Menit",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ===================== TOTAL =====================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Biaya Sparepart",
                                style: TextStyle(color: Colors.white70)),
                            SizedBox(height: 5),
                            Text("Rp. 65.000",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context); // 🔥 BALIK KE HALAMAN SPK
                              },
                              child: const Text("Batal"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context); // 🔥 sementara balik juga (nanti bisa simpan data)
                              },
                              icon: const Icon(Icons.save),
                              label: const Text("Simpan Data Servis"),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= COMPONENT =================

  Widget sectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget input(String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget dropdown(String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField(
        items: const [
          DropdownMenuItem(value: "1", child: Text("Option")),
        ],
        onChanged: (v) {},
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}