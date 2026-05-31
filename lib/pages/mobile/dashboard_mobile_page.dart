import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 Tambahan: Untuk koneksi Firestore
import 'package:intl/intl.dart'; // 👈 Tambahan: Untuk format rupiah otomatis
import 'keluhan_mobile_page.dart'; 
import 'servis_mobile_page.dart'; 
import 'akun_mobile_page.dart';
import 'detail_perawatan_page.dart';
import 'semua_perawatan_page.dart';
import 'katalog_barang_page.dart'; // 👈 Tambahan: Import halaman katalog barang

class DashboardMobilePage extends StatelessWidget {
  const DashboardMobilePage({super.key});

  // 🔥 LOGIKA GAMBAR PINTAR: Mencocokkan kategori dari database admin dengan aset gambar lokal kamu
  String _getGambarKategori(String kategori) {
    switch (kategori) {
      case "Oli":
        return "assets/oli_gardan.png"; // 👈 Sesuaikan dengan path aset oli kamu
      case "Filter":
        return "assets/primaxp.png";    // 👈 Sesuaikan dengan path aset filter kamu
      case "Kampas":
        return "assets/minyak_rem.png"; // 👈 Sesuaikan dengan path aset kampas kamu
      default:
        return "assets/shell_yellow.png"; // Gambar cadangan jika tidak ada yang cocok
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 8 Data Menu Layanan Lengkap dengan Detail Konten Dinamis
    final List<Map<String, dynamic>> layanan = [
      {
        "icon": Icons.build_circle, 
        "title": "Tune Up & Scanning Mesin",
        "image": "assets/tuneup.png", 
        "deskripsi": "Tune Up adalah proses standarisasi kembali kondisi mesin kendaraan Anda agar tetap prima. Melalui pemeriksaan menyeluruh, pembersihan sistem pembakaran, dan diagnosa sensor (scanning), Tune Up bertujuan mengembalikan efisiensi bahan bakar dan performa mesin yang mulai menurun akibat pemakaian harian.",
        "estimasi": "2 - 3 Jam",
        "garansi": "1 Bulan / 1.000 Km",
        "interval": "Tiap 10.000 Km / 6 Bulan",
        "harga": "Rp200.000 (Hanya Jasa)",
        "pekerjaan": [
          "Penyetelan Klep (Valve Clearance): Mengembalikan performa kompresi mesin",
          "Pemeriksaan Pengapian: Cek/Ganti Busi & Coil Pack.",
          "Sistem Kelistrikan Aki: Cek voltase & penambahan air aki.",
          "Sistem Filtrasi: Pembersihan/Penggantian Filter Udara & Filter BBM.",
          "Pemeriksaan Drive Belt: Cek kondisi Fan Belt, AC, & Power Steering.",
          "Cek Cairan Hidrolik: Penambahan Minyak Rem, Kopling, & Power Steering.",
          "Pelumasan Mesin: Cek volume & kualitas oli mesin.",
          "Sistem Pendingin & Wiper: Cek Air Radiator & Air Wiper."
        ]
      },
      {
        "icon": Icons.oil_barrel, 
        "title": "Ganti Oli",
        "image": "assets/ganti_oli.png",
        "deskripsi": "Layanan penggantian oli mesin secara berkala guna menjaga komponen dalam mesin tetap terlumasi dengan baik, mengurangi gesekan, serta mencegah keausan komponen internal.",
        "estimasi": "30 - 45 Menit",
        "garansi": "Saran Penggantian Berikutnya",
        "interval": "Tiap 5.000 Km s/d 10.000 Km",
        "harga": "Rp50.000 (Jasa Ganti Oli)",
        "pekerjaan": [
          "Pengurasan Oli Lama: Mengeluarkan sisa oli kotor secara maksimal.",
          "Penggantian Filter Oli: Memastikan sirkulasi oli baru tetap bersih.",
          "Pengisian Oli Baru: Sesuai takaran spesifikasi standar pabrikan Mitsubishi.",
          "Reset Indikator Oli: Sinkronisasi ulang pengingat di odometer."
        ]
      },
      {
        "icon": Icons.settings, 
        "title": "Servis Rem",
        "image": "assets/servis_rem.png",
        "deskripsi": "Pemeriksaan dan perawatan sistem pengereman demi keselamatan berkendara. Meliputi pembersihan komponen dari debu asbes, pelumasan kaliper, dan pengecekan ketebalan kampas.",
        "estimasi": "1 - 1.5 Jam",
        "garansi": "1 Minggu Pengerjaan",
        "interval": "Tiap 20.000 Km",
        "harga": "Rp120.000 (Sepaket Depan-Belakang)",
        "pekerjaan": [
          "Pembersihan Kampas Rem: Menghilangkan residu debu yang bikin rem berdecit.",
          "Bleeding Minyak Rem: Membuang gelembung udara pada sirkulasi hidrolik rem.",
          "Pelumasan Pin Kaliper: Mencegah rem macet atau macet sebelah.",
          "Pengukuran Ketebalan Piringan (Disc Brake): Memastikan batas aman pemakaian."
        ]
      },
      {
        "icon": Icons.menu_book, 
        "title": "Manual",
        "image": "assets/manual.png",
        "deskripsi": "Buku panduan digital mengenai standardisasi perawatan mandiri serta jadwal servis berkala resmi Bengkel Jimu Mitsubishi.",
        "estimasi": "-", "garansi": "-", "interval": "-", "harga": "Gratis (E-Book)",
        "pekerjaan": ["Membaca panduan servis", "Melihat jadwal perawatan berkala"]
      },
      {
        "icon": Icons.build, 
        "title": "Booking Servis",
        "image": "assets/booking.png",
        "deskripsi": "Fitur penjadwalan servis instan untuk menghindari antrean panjang di bengkel.",
        "estimasi": "Instan", "garansi": "-", "interval": "-", "harga": "Tanpa Biaya Tambahan",
        "pekerjaan": ["Pilih hari & jam servis", "Pilih mekanik andalan", "Konfirmasi kedatangan"]
      },
      {
        "icon": Icons.history, 
        "title": "Riwayat",
        "image": "assets/history.png",
        "deskripsi": "Rekam medis digital kendaraan Anda, mencakup seluruh riwayat servis yang pernah dilakukan.",
        "estimasi": "-", "garansi": "-", "interval": "-", "harga": "-",
        "pekerjaan": ["Melihat nota transaksi lama", "Mengecek daftar penggantian part sebelumnya"]
      },
      {
        "icon": Icons.feedback, 
        "title": "Keluhan",
        "estimasi": "-", "garansi": "-", "interval": "-", "harga": "-", "pekerjaan": []
      },
      {
        "icon": Icons.more_horiz, 
        "title": "Lainnya",
        "image": "assets/lainnya.png",
        "deskripsi": "Layanan modifikasi ringan, pasang aksesori, AC, atau pengerjaan kustom di luar paket standar.",
        "estimasi": "Kondisional", "garansi": "Sesuai Part", "interval": "-", "harga": "Hubungi Admin",
        "pekerjaan": ["Konsultasi pengerjaan khusus", "Pengecekan komponen tambahan"]
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ================= HEADER =================
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.car_repair, color: Colors.blue, size: 40);
                      },
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "JIMU MITSUBISHI",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Bengkel Terbaik",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: const Icon(Icons.person, color: Colors.orange),
                    ),
                  ],
                ),
              ),

              // ================= SEARCH =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari Nama Layanan",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= JUDUL =================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Jenis Perawatan dan Estimasi Biaya",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ================= GRID MENU LAYANAN =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: layanan.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final title = layanan[index]["title"];
                        
                        if (title == "Keluhan") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KeluhanMobilePage(),
                            ),
                          );
                        } 
                        else if (title == "Lainnya") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SemuaPerawatanPage(daftarLayanan: layanan),
                            ),
                          );
                        }
                        else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPerawatanPage(dataLayanan: layanan[index]),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              layanan[index]["icon"],
                              color: Colors.blue,
                              size: 28,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              layanan[index]["title"],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ================= KATALOG BARANG (KLIK LANGSUNG PINDAH HALAMAN) =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.centerLeft, // 👈 Memaksa seluruh isi Row di bawahnya mentok ke kiri
                  child: GestureDetector(
                    onTap: () {
                      // 🚀 SAAT DIPENCET: Pindah otomatis ke halaman penuh katalog
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const KatalogBarangPage()),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Agar area klik hanya sebatas tulisan dan panah saja
                      children: [
                        const Text(
                          "Katalog Barang",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(Icons.arrow_forward, color: Colors.blue.shade800, size: 20), // Sedikit sentuhan warna biru biar senada
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ================= HORIZONTAL LIST DATA NYAMBUNG FIREBASE =================
              SizedBox(
                height: 190, // Dinaikkan sedikit ke 190 agar border biru bawah tidak terpotong
                child: StreamBuilder<QuerySnapshot>(
                  // Mengambil data sparepart real-time yang diinput oleh Farid di Admin
                  stream: FirebaseFirestore.instance.collection('sparepart').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "Belum ada produk dari admin",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        
                        String kategoriBarang = data['kategori'] ?? "Oli";
                        String namaBarang = data['nama'] ?? "-";
                        int hargaJual = data['harga_jual'] ?? 0;
                        
                        // Format mata uang Rupiah
                        final formatRupiah = NumberFormat.currency(
                          locale: 'id_ID', 
                          symbol: 'Rp. ', 
                          decimalDigits: 0,
                        );

                        return Container(
                          width: 130,
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.blue, width: 1.5), // Sesuai mockup ber-border biru
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Gambar pintar otomatis menyedot dari logika kategori diatas
                              Expanded(
                                child: Image.asset(
                                  _getGambarKategori(kategoriBarang),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.oil_barrel,
                                      size: 45,
                                      color: Colors.orange,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                namaBarang,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                formatRupiah.format(hargaJual),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              // ================= KONTEN INFORMASI BENGKEL =================
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ALAMAT BENGKEL",
                                style: TextStyle(
                                  color: Colors.blue.shade800, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Jl. P. Damar gg Wijaya Kusuma No.10, Way Dadi, Kec. Sukarame, Kota Bandar Lampung, Lampung 35131",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "HUBUNGI KAMI",
                                style: TextStyle(
                                  color: Colors.blue.shade800, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.phone_android, color: Colors.blue.shade700, size: 14),
                                  const SizedBox(width: 4),
                                  const Expanded(
                                    child: Text(
                                      "0852-6986-4232\n(WhatsApp Chat)",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 11,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey.shade200, height: 1),
                    const SizedBox(height: 12),

                    Center(
                      child: Column(
                        children: [
                          const Text(
                            "© 2026 PT Karya Baik Bersama, Indonesia",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Login sebagai: ${user?.email ?? 'Pengguna'}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),

      // ================= BOTTOM NAVIGATION =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, 
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const ServisMobilePage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const AkunMobilePage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: "Servis",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Akun",
          ),
        ],
      ),
    );
  }
}