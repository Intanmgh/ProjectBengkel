import 'package:flutter/material.dart';

class TambahServisPage extends StatelessWidget {
  const TambahServisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= LEFT =================
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    cardSPK(),
                    const SizedBox(height: 15),

                    cardSparepart(),
                    const SizedBox(height: 15),

                    cardRincian(),
                    const SizedBox(height: 15),

                    cardPembayaran(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 20),

            // ================= RIGHT =================
            Expanded(
              flex: 1,
              child: summaryCard(context),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD SPK =================
  Widget cardSPK() {
    return card(
      "Masukkan Nomor SPK",
      Column(
        children: [
          input("Cari Nomor SPK"),
          const SizedBox(height: 10),

          DataTable(
            border: TableBorder.all(color: Colors.grey.shade300),
            columns: const [
              DataColumn(label: Text("Nomor SPK")),
              DataColumn(label: Text("Nama Pelanggan")),
              DataColumn(label: Text("Kendaraan")),
              DataColumn(label: Text("Total Harga")),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text("SPK - 001",
                    style: TextStyle(color: Colors.blue))),
                DataCell(Text("Farid Shidiq")),
                DataCell(Text("Mazda 3 HB")),
                DataCell(Text("Rp. 65.000")),
              ])
            ],
          )
        ],
      ),
    );
  }

  // ================= CARD SPAREPART =================
  Widget cardSparepart() {
    return card(
      "Tambah Sparepart Tambahan",
      Column(
        children: [
          Row(
            children: [
              Expanded(child: input("Cari sparepart")),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text("Tambah item"),
              )
            ],
          ),
          const SizedBox(height: 10),

          DataTable(
            border: TableBorder.all(color: Colors.grey.shade300),
            columns: const [
              DataColumn(label: Text("Nama")),
              DataColumn(label: Text("Kode")),
              DataColumn(label: Text("Jumlah")),
              DataColumn(label: Text("Harga")),
              DataColumn(label: Text("Total")),
              DataColumn(label: Text("Aksi")),
            ],
            rows: [
              DataRow(cells: [
                const DataCell(Text("Filter Oli")),
                const DataCell(Text("MD12301")),
                const DataCell(Text("1")),
                const DataCell(Text("Rp. 65.000")),
                const DataCell(Text("Rp. 65.000")),
                DataCell(Icon(Icons.delete, color: Colors.red)),
              ])
            ],
          )
        ],
      ),
    );
  }

  // ================= CARD RINCIAN =================
  Widget cardRincian() {
    return card(
      "Rincian Biaya Akhir",
      Column(
        children: [
          rowText("Biaya Jasa Servis", "Rp 45.000"),
          const SizedBox(height: 10),
          rowText("Total Biaya Sparepart", "Rp 1.465.000"),
        ],
      ),
    );
  }

  // ================= CARD PEMBAYARAN =================
  Widget cardPembayaran() {
    return card(
      "Metode Pembayaran",
      Row(
        children: [
          Expanded(child: paymentCard("Tunai (Cash)", Icons.money)),
          const SizedBox(width: 10),
          Expanded(child: paymentCard("Transfer Bank", Icons.account_balance)),
        ],
      ),
    );
  }

  // ================= SUMMARY =================
  Widget summaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "RINGKASAN BIAYA",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 15),

          rowText("Subtotal Jasa", "Rp 45.000"),
          rowText("Subtotal Sparepart", "Rp 1.465.000"),
          rowText("Pajak (PPN 11%)", "Rp 10.000"),

          const Divider(),

          const Text("TOTAL BIAYA AKHIR"),
          const SizedBox(height: 5),

          const Text(
            "Rp 1.500.000",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: () {},
            icon: const Icon(Icons.save),
            label: const Text("Simpan & Selesaikan"),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Batal Transaksi"),
          ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.print),
            label: const Text("Cetak Invoice"),
          )
        ],
      ),
    );
  }

  // ================= COMPONENT =================

  Widget card(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          child
        ],
      ),
    );
  }

  Widget input(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget rowText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget paymentCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 10),
          Text(title),
        ],
      ),
    );
  }
}