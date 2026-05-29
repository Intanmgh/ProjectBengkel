import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'keluhan_mobile_page.dart'; 
import 'servis_mobile_page.dart'; 
import 'akun_mobile_page.dart';
import 'detail_perawatan_page.dart';
import 'semua_perawatan_page.dart';
// import 'servis_mobile_page.dart'; // Buka komen ini jika file Servis sudah ada
// import 'akun_mobile_page.dart';   // Buka komen ini jika file Akun sudah ada

class DashboardMobilePage extends StatelessWidget {
  const DashboardMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 8 Data Menu Layanan Orisinal Sesuai Kodingan Anda
   // 8 Data Menu Layanan Lengkap dengan Detail Konten Dinamis
    final List<Map<String, dynamic>> layanan = [
      {
        "icon": Icons.build_circle, 
        "title": "Tune Up & Scanning Mesin",
        "image": "assets/tuneup.png", // Taruh gambarmu di assets jika ada
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
        // Menu Keluhan punya penanganan navigasi tersendiri (ke file keluhan)
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
                        
                        // 1. Navigasi khusus Menu Keluhan ke KeluhanMobilePage
                        if (title == "Keluhan") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KeluhanMobilePage(),
                            ),
                          );
                        } 
                        // 2. Navigasi khusus Menu Lainnya ke SemuaPerawatanPage
                        else if (title == "Lainnya") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SemuaPerawatanPage(daftarLayanan: layanan),
                            ),
                          );
                        }
                        // 3. Menu perawatan satuan langsung oper ke DetailPerawatanPage
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

              // ================= KATALOG BARANG =================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      "Katalog Barang",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    ProductCard(
                      nama: "Oli Mesin Shell",
                      harga: "Rp. 399.000",
                    ),
                    ProductCard(
                      nama: "Oli Helix",
                      harga: "Rp. 299.000",
                    ),
                    ProductCard(
                      nama: "Pertamina Fastron",
                      harga: "Rp. 299.000",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 🔵 KONTEN INFORMASI BENGKEL (SETEMA BIRU-PUTIH)
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
                        // Alamat Sukarame Baru Anda
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
                        
                        // Kontak Sukarame Baru Anda
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

                    // Copyright & Info Logged In User
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
        currentIndex: 0, // Beranda selalu aktif sebagai index 0 di file ini
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

// ================= PRODUCT CARD =================

class ProductCard extends StatelessWidget {
  final String nama;
  final String harga;

  const ProductCard({
    super.key,
    required this.nama,
    required this.harga,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.oil_barrel,
            size: 50,
            color: Colors.orange,
          ),
          const SizedBox(height: 10),
          Text(
            nama,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            harga,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}