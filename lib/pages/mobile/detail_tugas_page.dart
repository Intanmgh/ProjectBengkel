import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailTugasPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> dataSPK;

  const DetailTugasPage({
    super.key,
    required this.docId,
    required this.dataSPK,
  });

  @override
  State<DetailTugasPage> createState() => _DetailTugasPageState();
}

class _DetailTugasPageState extends State<DetailTugasPage> {
  late String currentStatus;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mengambil status awal dari data yang dikirim dashboard
    currentStatus = widget.dataSPK['status'] ?? 'Menunggu';
  }

  // Fungsi untuk memperbarui status pekerjaan di Firestore
  Future<void> updateStatus(String statusBaru) async {
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('spk')
          .doc(widget.docId)
          .update({
        'status': statusBaru,
        if (statusBaru == 'Proses') 'waktu_mulai': Timestamp.now(),
        if (statusBaru == 'Selesai') 'waktu_selesai': Timestamp.now(),
      });

      setState(() {
        currentStatus = statusBaru;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status berhasil diperbarui: $statusBaru")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui status: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data list sparepart dari Firestore (jika ada)
    final List<dynamic> spareparts = widget.dataSPK['sparepart'] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Detail Tugas Servis"),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= CARD INFORMASI KENDARAAN =================
                  _buildSectionTitle("Informasi Kendaraan & Pelanggan"),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow("No. Plat / Polisi", widget.dataSPK['plat'] ?? '-', isBold: true),
                        const Divider(),
                        _buildDetailRow("Nama Pelanggan", widget.dataSPK['nama_pelanggan'] ?? '-'),
                        _buildDetailRow("Model Mobil", widget.dataSPK['kendaraan'] ?? '-'),
                        _buildDetailRow("Jenis Servis", widget.dataSPK['jenis_servis'] ?? '-'),
                        _buildDetailRow("Estimasi Waktu", widget.dataSPK['estimasi'] ?? '-'),
                        _buildDetailRow("Status Saat Ini", currentStatus, isStatus: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ================= CARD KELUHAN UPTAMA =================
                  _buildSectionTitle("Keluhan Utama Pelanggan"),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      widget.dataSPK['keluhan'] ?? 'Tidak ada keluhan spesifik.',
                      style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ================= LIST CHECKLIST SPAREPART =================
                  _buildSectionTitle("Daftar Kebutuhan Sparepart"),
                  spareparts.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text("Tidak ada penggantian sparepart.", style: TextStyle(color: Colors.grey)),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: spareparts.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final part = spareparts[index] as Map<String, dynamic>;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade50,
                                  child: Text("${index + 1}", style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(part['nama_part'] ?? part['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text("Kode: ${part['kode'] ?? part['id'] ?? '-'}"),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "Qty: ${part['jumlah'] ?? 1}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 35),

                  // ================= TOMBOL AKSI UTAMA =================
                  if (currentStatus != 'Selesai')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentStatus == 'Menunggu' ? Colors.blue.shade700 : Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (currentStatus == 'Menunggu') {
                            updateStatus('Proses');
                          } else if (currentStatus == 'Proses') {
                            updateStatus('Selesai');
                          }
                        },
                        child: Text(
                          currentStatus == 'Menunggu' ? "MULAI KERJAKAN SEKARANG" : "NYATAKAN SERVIS SELESAI",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool isStatus = false}) {
    Color valColor = Colors.black87;
    if (isStatus) {
      if (value == 'Menunggu') valColor = Colors.orange.shade700;
      if (value == 'Proses') valColor = Colors.blue.shade700;
      if (value == 'Selesai') valColor = Colors.green.shade700;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: (isBold || isStatus) ? FontWeight.bold : FontWeight.normal,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }
}