import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// GLOBAL VARIABLE UNTUK MENAMPUNG DATA SPK YANG SEDANG DIKERJAKAN AKTIF
Map<String, dynamic>? spkAktifData;
String? spkAktifId;

class DashboardMontirPage extends StatefulWidget {
  const DashboardMontirPage({super.key});

  @override
  State<DashboardMontirPage> createState() => _DashboardMontirPageState();
}

class _DashboardMontirPageState extends State<DashboardMontirPage> {
  int _currentBottomIndex = 0;

  void ubahHalaman(int index) {
    setState(() {
      _currentBottomIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> halamanMenu = [
      KontenBerandaMontir(
        onKerjakanPressed: () => ubahHalaman(1),
        onProfilePressed: () => ubahHalaman(2), // Bisa klik profil
      ), 
      HalamanProsesServis(onSelesaiSemua: () => ubahHalaman(0)), 
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: halamanMenu[_currentBottomIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomIndex, 
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 15,
        onTap: ubahHalaman,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Servis"), 
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }
}

// =========================================================
// 1. HALAMAN BERANDA / DASHBOARD 
// =========================================================
class KontenBerandaMontir extends StatefulWidget {
  final VoidCallback onKerjakanPressed;
  final VoidCallback onProfilePressed; 
  const KontenBerandaMontir({super.key, required this.onKerjakanPressed, required this.onProfilePressed});

  @override
  State<KontenBerandaMontir> createState() => _KontenBerandaMontirState();
}

class _KontenBerandaMontirState extends State<KontenBerandaMontir> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String namaMontir = "Mekanik"; 
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getNamaMekanik();
  }

  void _getNamaMekanik() async {
    if (currentUid.isNotEmpty) {
      try {
        var userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUid).get();
        if (userDoc.exists && userDoc.data()?['nama'] != null) {
          setState(() {
            namaMontir = userDoc.data()?['nama'];
          });
        }
      } catch (e) {
        debugPrint("Gagal mengambil nama mekanik: $e");
      }
    }
  }

  void _tampilkanDetailSPK(BuildContext context, Map<String, dynamic> data, String deskripsiServis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50, height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.assignment, color: Colors.blue),
                  SizedBox(width: 8),
                  Text("Detail SPK Kendaraan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 30),
              
              _buildDetailRow("Pelanggan", data['nama_pelanggan'] ?? '-'),
              _buildDetailRow("Kendaraan", data['kendaraan'] ?? '-'),
              _buildDetailRow("Plat Nomor", data['plat'] ?? '-'),
              _buildDetailRow("Jam Masuk", data['jam_masuk'] ?? '-'),
              const Divider(height: 30),
              
              const Text("Keluhan / Catatan:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(data['keluhan'] ?? 'Tidak ada keluhan spesifik dicatat.', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              
              const Text("Jenis Penanganan:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(deskripsiServis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tutup", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          const Text(":  "),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('assets/logo.png', width: 35, errorBuilder: (c, e, s) => const Icon(Icons.car_repair, color: Colors.blue, size: 35)),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("JIMU MITSUBISHI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                        Text("Bengkel Terbaik", style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                // HEADER PROFIL YANG BISA DIKLIK
                InkWell(
                  onTap: widget.onProfilePressed, 
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      children: [
                        Text("Halo, $namaMontir", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11)),
                        const SizedBox(width: 6),
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.orange.shade100,
                          child: const Icon(Icons.face, size: 16, color: Colors.orange),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('spk')
                  .where('montir_uid', isEqualTo: currentUid)
                  .snapshots(),
              builder: (context, snapshot) {
                int totalTugasAktif = 0;
                int totalSelesai = 0;

                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'];
                    if (status == 'Selesai') {
                      totalSelesai++;
                    } else if (status == 'Menunggu' || status == 'Berjalan') {
                      totalTugasAktif++;
                    }
                  }
                }

                return Row(
                  children: [
                    _buildCounterBox("Tugas Aktif", "$totalTugasAktif Unit", Colors.blue.shade700),
                    const SizedBox(width: 12),
                    _buildCounterBox("Selesai", "$totalSelesai Unit", Colors.green.shade600),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            child: Align(alignment: Alignment.centerLeft, child: Text("Daftar Antrean SPK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          ),

          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blue.shade600,
            labelColor: Colors.blue.shade600,
            unselectedLabelColor: Colors.grey.shade400,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: "Menunggu"),
              Tab(text: "Berjalan"),
              Tab(text: "Selesai"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('Menunggu'),
                _buildTabContent('Berjalan'),
                _buildTabContent('Selesai'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterBox(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('spk')
          .where('montir_uid', isEqualTo: currentUid)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return Center(child: Text("Tidak ada data SPK $status", style: const TextStyle(color: Colors.grey)));

        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            bool isMenunggu = (status == 'Menunggu');
            bool isBerjalan = (status == 'Berjalan');

            String deskripsiServis = 'Servis Umum';
            if (data['jenis_servis'] != null) {
              if (data['jenis_servis'] is List) {
                List listServis = data['jenis_servis'];
                deskripsiServis = listServis.join(', ');
              } else {
                deskripsiServis = data['jenis_servis'].toString();
              }
            } else if (data['keluhan'] != null) {
              deskripsiServis = data['keluhan'].toString();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _tampilkanDetailSPK(context, data, deskripsiServis),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data['plat'] ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            _buildStatusBadge(status),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data['kendaraan'] ?? '-', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12)),
                            const Text("Lihat Detail SPK >", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.build_circle_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                deskripsiServis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(data['jam_masuk'] ?? "08:30 WIB", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        
                        if (status != 'Selesai') ...[
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () async {
                                if (isMenunggu) {
                                  await FirebaseFirestore.instance.collection('spk').doc(doc.id).update({'status': 'Berjalan'});
                                } else if (isBerjalan) {
                                  setState(() {
                                    spkAktifId = doc.id;
                                    spkAktifData = data;
                                  });
                                  widget.onKerjakanPressed(); 
                                }
                              },
                              child: Text(isMenunggu ? "MULAI KERJA SEKARANG" : "BUKA PANEL KERJA", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.orange.shade50; Color txt = Colors.orange.shade700; String label = "MENUNGGU";
    if (status == 'Berjalan') { bg = Colors.blue.shade50; txt = Colors.blue.shade700; label = "DIKERJAKAN"; }
    else if (status == 'Selesai') { bg = Colors.green.shade50; txt = Colors.green.shade700; label = "SELESAI"; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: txt, fontWeight: FontWeight.bold, fontSize: 9)),
    );
  }
}

// =========================================================================
// 2. HALAMAN CEKLIST PROSES SERVIS (DIKEMBALIKAN UTUH 100%)
// =========================================================================
class HalamanProsesServis extends StatelessWidget {
  final VoidCallback onSelesaiSemua;
  const HalamanProsesServis({super.key, required this.onSelesaiSemua});

  @override
  Widget build(BuildContext context) {
    if (spkAktifId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Silakan pilih SPK di Beranda & klik 'BUKA PANEL KERJA' terlebih dahulu",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('spk').doc(spkAktifId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        
        final docData = snapshot.data!.data() as Map<String, dynamic>?;
        if (docData == null) return const Scaffold(body: Center(child: Text("Data tidak ditemukan")));

        List<Map<String, dynamic>> listPekerjaanDinamis = [];
        String estimasiGlobal = docData['estimasi_waktu'] ?? '30';

        if (docData['items'] != null) {
          listPekerjaanDinamis = List<Map<String, dynamic>>.from(docData['items']);
        } else if (docData['jenis_servis'] != null) {
          if (docData['jenis_servis'] is List) {
            List listTeks = docData['jenis_servis'];
            for (var namaItem in listTeks) {
              if (namaItem.toString().trim().isNotEmpty) {
                listPekerjaanDinamis.add({
                  'nama': namaItem.toString().trim(),
                  'estimasi': estimasiGlobal,
                  'status': 'Belum Mulai'
                });
              }
            }
          } else {
            String teksDariAdmin = docData['jenis_servis'].toString();
            List<String> potonganServis = teksDariAdmin.split(',');
            for (var namaItem in potonganServis) {
              if (namaItem.trim().isNotEmpty) {
                listPekerjaanDinamis.add({
                  'nama': namaItem.trim(),
                  'estimasi': estimasiGlobal,
                  'status': 'Belum Mulai'
                });
              }
            }
          }
        }

        int totalTugas = listPekerjaanDinamis.length;
        int tugasSelesai = listPekerjaanDinamis.where((item) => item['status'] == 'Selesai').length;
        double persenProgress = totalTugas > 0 ? (tugasSelesai / totalTugas) : 0.0;
        
        // ==============================================================
        // VARIABEL VALIDASI: CEK APAKAH SEMUA TUGAS SUDAH DICENTANG
        // ==============================================================
        bool isSemuaSelesai = totalTugas > 0 && tugasSelesai == totalTugas;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text("Mekanik Live Tracking", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.5,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                onSelesaiSemua();
              },
            ),
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.blue.shade900.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.engineering, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(docData['kendaraan'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                              Text(docData['plat'] ?? '-', style: TextStyle(color: Colors.blue.shade100, fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
                          child: const Text("LIVE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                        )
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Progress Kerja: $tugasSelesai dari $totalTugas Selesai",
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          "${(persenProgress * 100).toInt()}%",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: persenProgress,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft, 
                  child: Text("Item Servis (Sentuh untuk Menyelesaikan):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                ),
              ),

              Expanded(
                child: listPekerjaanDinamis.isEmpty
                    ? const Center(child: Text("Tidak ada item ceklist.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: listPekerjaanDinamis.length,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        itemBuilder: (context, index) {
                          final item = listPekerjaanDinamis[index];
                          String namaTugas = item['nama'] ?? 'Item Servis';
                          String estimasiTugas = item['estimasi'] ?? '0';
                          bool isSelesai = item['status'] == 'Selesai';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelesai ? Colors.green.shade200 : Colors.grey.shade300),
                            ),
                            child: CheckboxListTile(
                              activeColor: Colors.green,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              title: Text(
                                namaTugas,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelesai ? Colors.grey : Colors.black87,
                                  decoration: isSelesai ? TextDecoration.lineThrough : TextDecoration.none,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  isSelesai ? "Selesai ditangani" : "Estimasi pengerjaan: $estimasiTugas Menit",
                                  style: TextStyle(fontSize: 11, color: isSelesai ? Colors.green : Colors.black54),
                                ),
                              ),
                              value: isSelesai,
                              onChanged: (bool? checked) async {
                                if (checked != null) {
                                  listPekerjaanDinamis[index]['status'] = checked ? 'Selesai' : 'Belum Mulai';
                                  await FirebaseFirestore.instance.collection('spk').doc(spkAktifId).update({
                                    'items': listPekerjaanDinamis
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),

              // ==============================================================
              // TOMBOL SELESAI DENGAN VALIDASI HARUS 100%
              // ==============================================================
              Padding(
                padding: const EdgeInsets.all(14),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSemuaSelesai ? Colors.blue.shade700 : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isSemuaSelesai 
                        ? () async {
                            await FirebaseFirestore.instance.collection('spk').doc(spkAktifId).update({
                              'status': 'Selesai',
                              'waktu_selesai': Timestamp.now()
                            });

                            spkAktifId = null;
                            spkAktifData = null;
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Laporan SPK berhasil dikirim, mobil siap diambil!")),
                            );
                            onSelesaiSemua();
                          }
                        : () {
                            // Memberikan pesan error kalau ditekan tapi belum 100%
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Selesaikan seluruh ceklist tugas terlebih dahulu!"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                child: Text(
                  isSemuaSelesai ? "SELESAI & SERAHKAN KUNCI" : "SELESAIKAN TUGAS DULU", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
                ),
              ),
            ),
          )
        ],
      ),
    );
  },
);
  }
}

// =========================================================
// 3. HALAMAN PROFIL (SUDAH DIPERBARUI)
// =========================================================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String _namaMontir = "Mekanik...";

  @override
  void initState() {
    super.initState();
    _loadNamaMekanik();
  }

  Future<void> _loadNamaMekanik() async {
    if (currentUser != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
        if (doc.exists && doc.data()?['nama'] != null) {
          setState(() {
            _namaMontir = doc.data()?['nama'];
          });
        }
      } catch (e) {
        debugPrint("Error load profil: $e");
      }
    }
  }

  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari akun mekanik ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: const Text("Ya, Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Profil Mekanik",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            // FOTO PROFIL (IKON)
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.engineering, size: 60, color: Colors.blue.shade800),
            ),
            const SizedBox(height: 20),
            
            // NAMA MEKANIK
            Text(
              _namaMontir,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // EMAIL MEKANIK
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    currentUser?.email ?? 'Email tidak ditemukan',
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // TOMBOL LOGOUT
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                ),
                onPressed: () => _konfirmasiLogout(context),
                icon: const Icon(Icons.logout),
                label: const Text("Keluar Akun (Logout)", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}