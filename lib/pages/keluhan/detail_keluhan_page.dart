import 'package:flutter/material.dart';

class DetailKeluhanPage extends StatelessWidget {
  final VoidCallback onBack;

  const DetailKeluhanPage({
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
                  "Manajemen Keluhan Pelanggan",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "Tanggapan & Resolusi Keluhan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            const Text(
              "Review pesan pelanggan dan berikan solusi tindak lanjut secara profesional",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // 🔥 CONTENT
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🔥 KIRI - PESAN
                  Expanded(
                    child: buildCard(
                      title: "PESAN PELANGGAN",
                      icon: Icons.message,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // 🔥 USER INFO
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.person, color: Colors.blue),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Rizki Mahesa",
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text("Mazda 3 HB | B 3214 CB",
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                )
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

                          // 🔥 ISI KELUHAN
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "“ Bunyi kasar pada area kaki kaki depan dan mesin melewati jalan bergelombang, terus ke mau rontok gitu ”",
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14),
                              SizedBox(width: 5),
                              Text("12 Februari 2026"),
                              SizedBox(width: 15),
                              Icon(Icons.access_time, size: 14),
                              SizedBox(width: 5),
                              Text("15:00 WIB"),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // 🔥 KANAN - TANGGAPAN
                  Expanded(
                    child: buildCard(
                      title: "UPDATE STATUS KELUHAN",
                      icon: Icons.access_time,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // 🔥 DROPDOWN
                          DropdownButtonFormField<String>(
                            initialValue: "Sedang Proses", // 🔥 FIX
                            items: const [
                              DropdownMenuItem(
                                value: "Sedang Proses",
                                child: Text("Sedang Proses"),
                              ),
                              DropdownMenuItem(
                                value: "Selesai",
                                child: Text("Selesai"),
                              ),
                            ],
                            onChanged: (value) {},
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // 🔥 TEXTAREA
                          TextField(
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText:
                                  "Tuliskan evaluasi dan tanggapan disini ya...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // 🔥 BUTTON
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: onBack,
                                  child: const Text("Batal"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {},
                                  icon: const Icon(Icons.save),
                                  label: const Text("Simpan Tanggapan"),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // 🔥 CARD
  Widget buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child
        ],
      ),
    );
  }
}