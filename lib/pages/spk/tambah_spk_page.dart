import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahSpkPage extends StatefulWidget {
  final VoidCallback onBack;

  const TambahSpkPage({
    super.key,
    required this.onBack,
  });

  @override
  State<TambahSpkPage> createState() => _TambahSpkPageState();
}

class _TambahSpkPageState extends State<TambahSpkPage> {
  // ================= DATA TERPILIH =================
  Map<String, dynamic>? selectedPelanggan;
  Map<String, dynamic>? selectedMontir;
  List<Map<String, dynamic>> selectedSpareparts = [];

  // ================= CONTROLLER =================
  final TextEditingController keluhanController = TextEditingController();
  List<String> selectedJenisServis = [];

  // ================= WAKTU =================
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedDurasi = "30 Menit"; // Default lebih masuk akal untuk satuan parsing

  bool isLoading = false;

  // ================= TOTAL HARGA =================
  int get totalHarga {
    int total = 0;
    for (var item in selectedSpareparts) {
      total += (int.parse(item['harga'].toString())) * (item['jumlah'] as int);
    }
    return total;
  }

  // ================= SIMPAN SPK =================
  Future<void> simpanSPK() async {
    // VALIDASI
    if (selectedPelanggan == null) {
      _showSnackbar("Pilih pelanggan dulu", isError: true);
      return;
    }

    if (keluhanController.text.trim().isEmpty) {
      _showSnackbar("Isi detail keluhan dulu", isError: true);
      return;
    }

    if (selectedJenisServis.isEmpty) {
      _showSnackbar("Pilih jenis servis dulu", isError: true);
      return;
    }

    if (selectedMontir == null) {
      _showSnackbar("Pilih montir dulu", isError: true);
      return;
    }

    if (selectedDate == null || selectedTime == null) {
      _showSnackbar("Pilih tanggal dan waktu dulu", isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      // ✅ SNAPSHOT HARGA SPAREPART SAAT INI
      final sparepartSnapshot = selectedSpareparts.map((item) => {
        'sparepart_id': item['id'],
        'nama': item['nama'],
        'kode': item['kode'],
        'harga_jual_saat_itu': item['harga'],
        'jumlah': item['jumlah'],
        'subtotal': int.parse(item['harga'].toString()) * (item['jumlah'] as int),
      }).toList();

      // ================= BUAT NOMOR SPK =================
      final now = DateTime.now();
      final waktuFormat = selectedTime!.format(context);
      final tahunBulan = "${now.year}${now.month.toString().padLeft(2, '0')}";
      final spkSnapshot = await FirebaseFirestore.instance.collection('spk').get();
      final urutan = (spkSnapshot.docs.length + 1).toString().padLeft(4, '0');
      final noSpk = "SPK-$tahunBulan-$urutan";

      // ================= FORMAT DATA BARU UNTUK MONTIR/PELANGGAN =================
      // Ubah "1 Jam" menjadi angka mentah "60" untuk Montir
      String estimasiMentah = selectedDurasi;
      if (selectedDurasi == "1 Jam") estimasiMentah = "60";
      else if (selectedDurasi == "2 Jam") estimasiMentah = "120";
      else if (selectedDurasi == "3 Jam") estimasiMentah = "180";
      else if (selectedDurasi == "5 Jam") estimasiMentah = "300";
      else if (selectedDurasi == "1 Hari") estimasiMentah = "1440";
      else {
        estimasiMentah = selectedDurasi.replaceAll(RegExp(r'[^0-9]'), '');
        if (estimasiMentah.isEmpty) estimasiMentah = "30";
      }

      // Buat struktur array checklist untuk dibaca montir dan pelanggan
      List<Map<String, dynamic>> itemsServisArray = selectedJenisServis.map((item) {
        return {
          'nama': item,
          'estimasi': estimasiMentah, // Simulasi menggunakan estimasi global
          'status': 'Belum Mulai',
        };
      }).toList();

      // ================= SIMPAN KE FIRESTORE =================
      await FirebaseFirestore.instance.collection('spk').add({
        'no_spk': noSpk,

        // DATA PELANGGAN (Wajib menyertakan email jika ada untuk sistem Tracking Pelanggan)
        'pelanggan_id': selectedPelanggan!['id'],
        'nama_pelanggan': selectedPelanggan!['nama'],
        'plat': selectedPelanggan!['plat'],
        'kendaraan': selectedPelanggan!['kendaraan'],
        'km': selectedPelanggan!['km'],
        // Menyimpan email jika tersedia di data pelanggan, agar fitur tracking by email berfungsi
        'email': selectedPelanggan!['email'] ?? '', 

        // DATA SERVIS
        'keluhan': keluhanController.text.trim(),
        'jenis_servis': selectedJenisServis, // Disimpan sebagai List
        'items': itemsServisArray, // Struktur Ceklist Dinamis

        // DATA MONTIR
        'montir_id': selectedMontir!['id'],
        'montir_uid': selectedMontir!['uid_akun'],
        'nama_montir': selectedMontir!['nama'],

        // DATA SPAREPART
        'sparepart': sparepartSnapshot,
        'total_harga': totalHarga,

        // DATA WAKTU
        'tanggal': "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}",
        'waktu': waktuFormat,
        'estimasi': selectedDurasi,
        'estimasi_waktu': estimasiMentah, // Field khusus agar sinkron dengan montir
        'jam_masuk': waktuFormat,

        // STATUS
        'status': 'Menunggu',
        'created_at': Timestamp.now(),
        'waktu_dibuat': Timestamp.now(),
      });

      if (!mounted) return;

      _showSnackbar("SPK berhasil disimpan!", isError: false);
      widget.onBack();

    } catch (e) {
      if (!mounted) return;
      _showSnackbar("Gagal simpan SPK: $e", isError: true);
    }

    setState(() => isLoading = false);
  }

  // ================= SNACKBAR HELPER =================
  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Buat Surat Perintah Kerja (SPK)",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              "Lengkapi formulir dibawah untuk mendaftarkan antrian servis",
            ),
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
                  // =====================================================
                  // 1. DATA PELANGGAN
                  // =====================================================
                  sectionTitle(Icons.person, "1. Data Pelanggan & Kendaraan"),
                  label("Cari Pelanggan / No. Plat"),

                  Autocomplete<Map<String, dynamic>>(
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text == '') {
                        return const Iterable<Map<String, dynamic>>.empty();
                      }
                      var result = await FirebaseFirestore.instance.collection('pelanggan').get();
                      return result.docs
                          .map((e) => {
                                'id': e.id,
                                'nama': e['nama'],
                                'plat': e['plat'],
                                'kendaraan': e['kendaraan'],
                                'km': e['km'] ?? '-',
                                'email': e.data().containsKey('email') ? e['email'] : '', // Mengambil email jika ada
                              })
                          .where((item) =>
                              item['nama'].toString().toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                              item['plat'].toString().toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    displayStringForOption: (option) => option['nama'],
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: "Contoh: B 1234 ABC atau nama pelanggan",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      );
                    },
                    onSelected: (option) {
                      setState(() => selectedPelanggan = option);
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: Container(
                            width: 400,
                            color: Colors.white,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option['nama']),
                                  subtitle: Text(option['plat']),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  DataTable(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columns: const [
                      DataColumn(label: Text("Nama Pelanggan")),
                      DataColumn(label: Text("No. Plat")),
                      DataColumn(label: Text("Kendaraan")),
                      DataColumn(label: Text("KM Terakhir")),
                    ],
                    rows: selectedPelanggan == null
                        ? []
                        : [
                            DataRow(cells: [
                              DataCell(Text(selectedPelanggan!['nama'])),
                              DataCell(Text(selectedPelanggan!['plat'])),
                              DataCell(Text(selectedPelanggan!['kendaraan'])),
                              DataCell(Text(selectedPelanggan!['km'].toString())),
                            ])
                          ],
                  ),

                  const SizedBox(height: 25),

                  // =====================================================
                  // 2. KELUHAN
                  // =====================================================
                  sectionTitle(Icons.description, "2. Keluhan & Jenis Servis"),
                  label("Detail Keluhan"),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: keluhanController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Contoh: Mesin berisik saat jalan",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  label("Jenis Servis"),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        "Ganti Oli",
                        "Servis Ringan",
                        "Servis Berat",
                        "Tune Up",
                        "Spooring & Balancing",
                        "Ganti Kampas Rem",
                        "Servis AC",
                        "Overhaul Mesin",
                        "Servis Kelistrikan",
                        "Ganti Ban",
                        "Cek Mesin",
                        "Lainnya",
                      ].map((servis) {
                        return FilterChip(
                          label: Text(servis),
                          selected: selectedJenisServis.contains(servis),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedJenisServis.add(servis);
                              } else {
                                selectedJenisServis.remove(servis);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =====================================================
                  // 3. MONTIR
                  // =====================================================
                  sectionTitle(Icons.engineering, "3. Pilih Montir"),
                  label("Montir Yang Bertugas"),

                  Autocomplete<Map<String, dynamic>>(
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text == '') {
                        return const Iterable<Map<String, dynamic>>.empty();
                      }
                      var result = await FirebaseFirestore.instance.collection('montir').get();
                      return result.docs
                          .map((e) {
                            final data = e.data();
                            return {
                              'id': e.id,
                              'nama': data['nama'] ?? '',
                              'uid_akun': data['uid_akun'] ?? '',
                            };
                          })
                          .where((item) => item['nama'].toString().toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    displayStringForOption: (option) => option['nama'],
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: "Cari montir",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      );
                    },
                    onSelected: (option) {
                      setState(() => selectedMontir = option);
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: Container(
                            width: 400,
                            color: Colors.white,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option['nama']),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  if (selectedMontir != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        "Montir dipilih: ${selectedMontir!['nama']}",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 25),

                  // =====================================================
                  // 4. SPAREPART
                  // =====================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      sectionTitle(Icons.build, "4. Pilih Sparepart"),
                    ],
                  ),

                  Autocomplete<Map<String, dynamic>>(
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text == '') {
                        return const Iterable<Map<String, dynamic>>.empty();
                      }
                      var result = await FirebaseFirestore.instance.collection('sparepart').get();
                      return result.docs
                          .map((e) => {
                                'id': e.id,
                                'nama': e['nama'],
                                'kode': e['kode'],
                                'harga': e['harga_jual'],
                              })
                          .where((item) =>
                              item['nama'].toString().toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                              item['kode'].toString().toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    displayStringForOption: (option) => option['nama'],
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: "Cari nama sparepart / kode",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      );
                    },
                    onSelected: (option) {
                      bool sudahAda = selectedSpareparts.any((item) => item['id'] == option['id']);
                      if (sudahAda) {
                        _showSnackbar(
                          "Sparepart sudah ditambahkan",
                          isError: true,
                        );
                        return;
                      }
                      setState(() {
                        selectedSpareparts.add({...option, 'jumlah': 1});
                      });
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: Container(
                            width: 400,
                            color: Colors.white,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option['nama']),
                                  subtitle: Text(option['kode']),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // TABEL SPAREPART
                  if (selectedSpareparts.isNotEmpty)
                    DataTable(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columns: const [
                        DataColumn(label: Text("Nama Sparepart")),
                        DataColumn(label: Text("Kode")),
                        DataColumn(label: Text("Jumlah")),
                        DataColumn(label: Text("Harga Satuan")),
                        DataColumn(label: Text("Subtotal")),
                        DataColumn(label: Text("Aksi")),
                      ],
                      rows: selectedSpareparts.map((item) {
                        final harga = int.parse(item['harga'].toString());
                        final jumlah = item['jumlah'] as int;
                        final subtotal = harga * jumlah;

                        return DataRow(cells: [
                          DataCell(Text(item['nama'])),
                          DataCell(Text(item['kode'])),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (item['jumlah'] > 1) {
                                        item['jumlah']--;
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.remove, size: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text("$jumlah"),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() => item['jumlah']++);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.add, size: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text("Rp ${_formatRupiah(harga)}")),
                          DataCell(Text("Rp ${_formatRupiah(subtotal)}")),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => selectedSpareparts.remove(item));
                              },
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),

                  const SizedBox(height: 25),

                  // =====================================================
                  // 5. WAKTU
                  // =====================================================
                  sectionTitle(Icons.access_time, "5. Pilih Waktu"),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      // TANGGAL
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "TANGGAL MULAI",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2024),
                                  lastDate: DateTime(2030),
                                );
                                if (pickedDate != null) {
                                  setState(() => selectedDate = pickedDate);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedDate == null
                                          ? "Pilih Tanggal"
                                          : "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      // WAKTU
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "WAKTU MULAI",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (pickedTime != null) {
                                  setState(() => selectedTime = pickedTime);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedTime == null ? "Pilih Waktu" : selectedTime!.format(context),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Icon(Icons.access_time, color: Colors.grey, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      // ESTIMASI
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ESTIMASI PENGERJAAN",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: selectedDurasi,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(value: "30 Menit", child: Text("30 Menit")),
                                DropdownMenuItem(value: "1 Jam", child: Text("1 Jam")),
                                DropdownMenuItem(value: "2 Jam", child: Text("2 Jam")),
                                DropdownMenuItem(value: "3 Jam", child: Text("3 Jam")),
                                DropdownMenuItem(value: "5 Jam", child: Text("5 Jam")),
                                DropdownMenuItem(value: "1 Hari", child: Text("1 Hari")),
                                DropdownMenuItem(value: "2 Hari", child: Text("2 Hari")),
                                DropdownMenuItem(value: "3 Hari", child: Text("3 Hari")),
                                DropdownMenuItem(value: "1 Minggu", child: Text("1 Minggu")),
                              ],
                              onChanged: (value) {
                                setState(() => selectedDurasi = value!);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // =====================================================
                  // TOTAL & TOMBOL
                  // =====================================================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total Biaya Sparepart",
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Rp ${_formatRupiah(totalHarga)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: widget.onBack,
                              child: const Text("Batal"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue.shade800,
                              ),
                              onPressed: isLoading ? null : simpanSPK,
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(
                                isLoading ? "Menyimpan..." : "Simpan Data Servis",
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // ================= FORMAT RUPIAH =================
  String _formatRupiah(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}