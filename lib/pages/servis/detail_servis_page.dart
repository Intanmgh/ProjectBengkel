import 'package:flutter/material.dart';

class DetailServisPage extends StatelessWidget {
  final VoidCallback onBack;

  const DetailServisPage({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xfff5f7fb),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
                  "Pencatatan Data Servis",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 TITLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "#INVOICE",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.print),
                      label: const Text("Cetak Invoice"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Unduh PDF"),
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 INVOICE
            Expanded(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8, // 🔥 RESPONSIVE LEBAR
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                      )
                    ],
                  ),

                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // 🔥 HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            // 🔥 KIRI (LOGO + INFO)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // 🔥 LOGO BESAR
                                Image.asset(
                                  'assets/logo.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),

                                const SizedBox(width: 15),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "JIMU MITSUBISHI",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text("Bengkel Terbaik"),
                                    SizedBox(height: 10),
                                    Text("JL. P DAMAR GG WIJAYA KESUMA NO.10"),
                                    Text("BANDAR LAMPUNG"),
                                    Text("Telp: 08213123412"),
                                  ],
                                ),
                              ],
                            ),

                            // 🔥 KANAN
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("No Invoice : INVOICE-123244"),
                                Text("Nama Pelanggan : Farid Shidiq"),
                                Text("Nama Montir : Farid Shidiq"),
                                Text("No Plat : B 1324 CB"),
                                Text("Kendaraan : Mazda 3 HB"),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // 🔥 HEADER TABLE
                        Row(
                          children: const [
                            Expanded(child: Text("No.", style: TextStyle(color: Colors.blue))),
                            Expanded(flex: 3, child: Text("Deskripsi Jasa/Sparepart", style: TextStyle(color: Colors.blue))),
                            Expanded(child: Text("Jumlah", style: TextStyle(color: Colors.blue))),
                            Expanded(child: Text("Harga Satuan", style: TextStyle(color: Colors.blue))),
                            Expanded(child: Text("Subtotal", style: TextStyle(color: Colors.blue))),
                          ],
                        ),

                        const Divider(),

                        invoiceRow("01", "Ganti Filter Oli", "1", "Rp 65.000", "Rp 65.000"),
                        invoiceRow("02", "Tuneup", "1", "Rp 165.000", "Rp 165.000"),
                        invoiceRow("03", "Brake Font Set", "2", "Rp 465.000", "Rp 1.650.000"),

                        const Divider(),

                        const SizedBox(height: 15),

                        // 🔥 TOTAL
                        Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Total Servis: Rp 2.650.000"),
                              SizedBox(height: 5),
                              Text("Harga Jasa Servis: Rp 250.000"),
                              SizedBox(height: 5),
                              Text("Pajak (PPN 10%): Rp 50.000"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),
                        const Divider(),

                        // 🔥 TOTAL AKHIR
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Total Akhir Dibayarkan :",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Rp 2.465.000",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("Pembayaran :"),
                            Text(
                              "CASH",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "*Simpan invoice ini sebagai garansi saat ada\n"
                          "yang kurang bla bla bla",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),

                        const SizedBox(height: 25),

                        const Center(
                          child: Text(
                            "TERIMA KASIH ATAS KEPERCAYAAN ANDA\nMENGGUNAKAN JASA KAMI",
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Center(
                          child: Text(
                            "JIMU MITSUBISHI | BENGKEL TERBAIK",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget invoiceRow(
      String no, String desc, String qty, String price, String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(no)),
          Expanded(flex: 3, child: Text(desc)),
          Expanded(child: Text(qty)),
          Expanded(child: Text(price)),
          Expanded(child: Text(total)),
        ],
      ),
    );
  }
}