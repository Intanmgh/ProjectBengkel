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

// 🔥 WAKTU

DateTime? selectedDate;

TimeOfDay? selectedTime;

String selectedDurasi = "1 Jam";

// 🔥 TOTAL HARGA SPAREPART
int get totalHarga {

  int total = 0;

  for (var item in selectedSpareparts) {

    total += int.parse(
      item['harga'].toString(),
    );
  }

  return total;
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

            // 🔥 HEADER + BACK
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

                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  // =====================================================
                  // 1. DATA PELANGGAN
                  // =====================================================

                  sectionTitle(
                    Icons.person,
                    "1. Data Pelanggan & Kendaraan",
                  ),

                  label("Cari Pelanggan / No. Plat"),

                  Autocomplete<Map<String, dynamic>>(

                    optionsBuilder: (
                      TextEditingValue textEditingValue,
                    ) async {

                      if (textEditingValue.text == '') {
                        return const Iterable<
                            Map<String, dynamic>>.empty();
                      }

                      var result = await FirebaseFirestore.instance
                          .collection('pelanggan')
                          .get();

                      return result.docs
                          .map((e) => {
                                'id': e.id,
                                'nama': e['nama'],
                                'plat': e['plat'],
                                'kendaraan': e['kendaraan'],
                                'km': e['km'] ?? '-',
                              })

                          .where((item) =>

                              item['nama']
                                  .toString()
                                  .toLowerCase()
                                  .contains(
                                    textEditingValue.text.toLowerCase(),
                                  ) ||

                              item['plat']
                                  .toString()
                                  .toLowerCase()
                                  .contains(
                                    textEditingValue.text.toLowerCase(),
                                  ));
                    },

                    displayStringForOption: (option) =>
                        option['nama'],

                    fieldViewBuilder:
                        (
                          context,
                          controller,
                          focusNode,
                          onEditingComplete,
                        ) {

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),

                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,

                          decoration: InputDecoration(
                            hintText:
                                "Contoh: B 1234 ABC atau nama pelanggan",

                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      );
                    },

                    onSelected: (option) {

                      setState(() {
                        selectedPelanggan = option;
                      });
                    },

                    optionsViewBuilder:
                        (
                          context,
                          onSelected,
                          options,
                        ) {

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

                                final option =
                                    options.elementAt(index);

                                return ListTile(
                                  title: Text(option['nama']),
                                  subtitle: Text(option['plat']),

                                  onTap: () {
                                    onSelected(option);
                                  },
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
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                    ),

                    columns: const [
                      DataColumn(label: Text("Nama Pelanggan")),
                      DataColumn(label: Text("No. Plat")),
                      DataColumn(label: Text("Kendaraan")),
                      DataColumn(label: Text("KM Terakhir")),
                    ],

                    rows: selectedPelanggan == null
                        ? []
                        : [
                            DataRow(
                              cells: [

                                DataCell(
                                  Text(selectedPelanggan!['nama']),
                                ),

                                DataCell(
                                  Text(selectedPelanggan!['plat']),
                                ),

                                DataCell(
                                  Text(selectedPelanggan!['kendaraan']),
                                ),

                                DataCell(
                                  Text(
                                    selectedPelanggan!['km']
                                        .toString(),
                                  ),
                                ),
                              ],
                            )
                          ],
                  ),

                  const SizedBox(height: 25),

                  // =====================================================
                  // 2. KELUHAN
                  // =====================================================

                  sectionTitle(
                    Icons.description,
                    "2. Keluhan & Jenis Servis",
                  ),

                  label("Detail Keluhan"),

                  input(
                    "Contoh: Mesin berisik saat jalan",
                    maxLines: 3,
                  ),

                  const SizedBox(height: 10),

                  label("Jenis Servis"),

Padding(
  padding: const EdgeInsets.only(bottom: 10),

  child: DropdownButtonFormField<String>(

    decoration: InputDecoration(
      hintText: "Pilih jenis servis",

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    items: const [

      DropdownMenuItem(
        value: "Ganti Oli",
        child: Text("Ganti Oli"),
      ),

      DropdownMenuItem(
        value: "Servis Ringan",
        child: Text("Servis Ringan"),
      ),

      DropdownMenuItem(
        value: "Servis Berat",
        child: Text("Servis Berat"),
      ),

      DropdownMenuItem(
        value: "Tune Up",
        child: Text("Tune Up"),
      ),

      DropdownMenuItem(
        value: "Spooring & Balancing",
        child: Text("Spooring & Balancing"),
      ),

      DropdownMenuItem(
        value: "Ganti Kampas Rem",
        child: Text("Ganti Kampas Rem"),
      ),

      DropdownMenuItem(
        value: "Servis AC",
        child: Text("Servis AC"),
      ),

      DropdownMenuItem(
        value: "Overhaul Mesin",
        child: Text("Overhaul Mesin"),
      ),

      DropdownMenuItem(
        value: "Servis Kelistrikan",
        child: Text("Servis Kelistrikan"),
      ),

      DropdownMenuItem(
        value: "Ganti Ban",
        child: Text("Ganti Ban"),
      ),

      DropdownMenuItem(
        value: "Cek Mesin",
        child: Text("Cek Mesin"),
      ),

      DropdownMenuItem(
        value: "Lainnya",
        child: Text("Lainnya"),
      ),
    ],

    onChanged: (value) {

      setState(() {

      });
    },
  ),
),

                  const SizedBox(height: 25),

                  // =====================================================
                  // 3. MONTIR
                  // =====================================================

                  sectionTitle(
                    Icons.engineering,
                    "3. Pilih Montir",
                  ),

                  label("Montir Yang Bertugas"),

                  Autocomplete<Map<String, dynamic>>(

                    optionsBuilder: (
                      TextEditingValue textEditingValue,
                    ) async {

                      if (textEditingValue.text == '') {
                        return const Iterable<
                            Map<String, dynamic>>.empty();
                      }

                      var result = await FirebaseFirestore.instance
                          .collection('montir')
                          .get();

                      return result.docs
                          .map((e) => {
                                'id': e.id,
                                'nama': e['nama'],
                              })

                          .where((item) =>

                              item['nama']
                                  .toString()
                                  .toLowerCase()
                                  .contains(
                                    textEditingValue.text.toLowerCase(),
                                  ));
                    },

                    displayStringForOption: (option) =>
                        option['nama'],

                    fieldViewBuilder:
                        (
                          context,
                          controller,
                          focusNode,
                          onEditingComplete,
                        ) {

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),

                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,

                          decoration: InputDecoration(
                            hintText: "Cari montir",

                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      );
                    },

                    onSelected: (option) {

                      setState(() {
                        selectedMontir = option;
                      });
                    },

                    optionsViewBuilder:
                        (
                          context,
                          onSelected,
                          options,
                        ) {

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

                                final option =
                                    options.elementAt(index);

                                return ListTile(
                                  title: Text(option['nama']),

                                  onTap: () {
                                    onSelected(option);
                                  },
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
                        "Montir dipilih : ${selectedMontir!['nama']}",

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
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [

                      sectionTitle(
                        Icons.build,
                        "4. Pilih Sparepart",
                      ),

                      TextButton.icon(
                        onPressed: () {},

                        icon: const Icon(
                          Icons.add,
                          color: Colors.blue,
                        ),

                        label: const Text("Tambah item"),
                      )
                    ],
                  ),

                  Autocomplete<Map<String, dynamic>>(

                    optionsBuilder: (
                      TextEditingValue textEditingValue,
                    ) async {

                      if (textEditingValue.text == '') {
                        return const Iterable<
                            Map<String, dynamic>>.empty();
                      }

                      var result = await FirebaseFirestore.instance
                          .collection('sparepart')
                          .get();

                      return result.docs
                          .map((e) => {
                                'id': e.id,
                                'nama': e['nama'],
                                'kode': e['kode'],
                                'harga': e['harga_jual'],
                              })

                          .where((item) =>

                              item['nama']
                                  .toString()
                                  .toLowerCase()
                                  .contains(
                                    textEditingValue.text.toLowerCase(),
                                  ) ||

                              item['kode']
                                  .toString()
                                  .toLowerCase()
                                  .contains(
                                    textEditingValue.text.toLowerCase(),
                                  ));
                    },

                    displayStringForOption: (option) =>
                        option['nama'],

                    fieldViewBuilder:
                        (
                          context,
                          controller,
                          focusNode,
                          onEditingComplete,
                        ) {

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),

                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,

                          decoration: InputDecoration(
                            hintText:
                                "Cari nama sparepart/code",

                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      );
                    },

                    onSelected: (option) {

                    bool sudahAda = selectedSpareparts.any(
                      (item) => item['id'] == option['id'],
                    );

                    if (sudahAda) {

                      ScaffoldMessenger.of(context).showSnackBar(

                        const SnackBar(
                          content: Text(
                            "Sparepart sudah ditambahkan",
                          ),
                        ),
                      );

                      return;
                    }

                    setState(() {

                      selectedSpareparts.add({
                        ...option,
                        'jumlah': 1,
                      });
                    });
},

                    optionsViewBuilder:
                        (
                          context,
                          onSelected,
                          options,
                        ) {

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

                                final option =
                                    options.elementAt(index);

                                return ListTile(
                                  title: Text(option['nama']),
                                  subtitle: Text(option['kode']),

                                  onTap: () {
                                    onSelected(option);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  DataTable(
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                    ),

                    columns: const [
                      DataColumn(label: Text("Nama Sparepart")),
                      DataColumn(label: Text("Kode")),
                      DataColumn(label: Text("Jumlah")),
                      DataColumn(label: Text("Harga")),
                      DataColumn(label: Text("Aksi")),
                    ],

                    rows: selectedSpareparts.map((item) {

                      return DataRow(
                        cells: [

                          DataCell(
                            Text(item['nama']),
                          ),

                          DataCell(
                            Text(item['kode']),
                          ),

                          DataCell(
                            Text(item['jumlah'].toString()),
                          ),

                          DataCell(
                            Text("Rp. ${item['harga']}"),
                          ),

                          DataCell(
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),

                              onPressed: () {

                                setState(() {
                                  selectedSpareparts.remove(item);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 25),

                  // =====================================================
// 5. WAKTU
// =====================================================

sectionTitle(
  Icons.access_time,
  "5. Pilih Waktu",
),

const SizedBox(height: 15),

Row(
  children: [

    // ================= TANGGAL =================

Expanded(
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,

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

          DateTime? pickedDate =
              await showDatePicker(
            context: context,

            initialDate: DateTime.now(),

            firstDate: DateTime(2024),

            lastDate: DateTime(2030),
          );

          if (pickedDate != null) {

            setState(() {
              selectedDate = pickedDate;
            });
          }
        },

        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),

          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade400,
            ),

            borderRadius:
                BorderRadius.circular(8),
          ),

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [

              Text(

                selectedDate == null
                    ? "Pilih Tanggal"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Icon(
                Icons.calendar_today,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(width: 20),

    // ================= WAKTU =================

Expanded(
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,

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

          TimeOfDay? pickedTime =
              await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (pickedTime != null) {

            setState(() {
              selectedTime = pickedTime;
            });
          }
        },  

        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),

          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade400,
            ),

            borderRadius:
                BorderRadius.circular(8),
          ),

          child: Text(

            selectedTime == null
                ? "Pilih Waktu"
                : selectedTime!.format(context),

            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(width: 20),

// ================= DURASI =================

Expanded(
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,

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
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(8),
          ),
        ),

        items: const [

        DropdownMenuItem(
          value: "30 Menit",
          child: Text("30 Menit"),
        ),

        DropdownMenuItem(
          value: "1 Jam",
          child: Text("1 Jam"),
        ),

        DropdownMenuItem(
          value: "2 Jam",
          child: Text("2 Jam"),
        ),

        DropdownMenuItem(
          value: "3 Jam",
          child: Text("3 Jam"),
        ),

        DropdownMenuItem(
          value: "5 Jam",
          child: Text("5 Jam"),
        ),

        DropdownMenuItem(
          value: "1 Hari",
          child: Text("1 Hari"),
        ),

        DropdownMenuItem(
          value: "2 Hari",
          child: Text("2 Hari"),
        ),

        DropdownMenuItem(
          value: "3 Hari",
          child: Text("3 Hari"),
        ),

        DropdownMenuItem(
          value: "1 Minggu",
          child: Text("1 Minggu"),
        ),
      ],

        onChanged: (value) {

          setState(() {
            selectedDurasi = value!;
          });
        },
      ),
    ],
  ),
),

const SizedBox(width: 20),

// ================= TOTAL DURASI =================

// ================= TOTAL DURASI =================

Expanded(
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,

    children: [

      const Text(
        "TOTAL DURASI",

        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),

      const SizedBox(height: 8),

      Container(
        width: double.infinity,

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),

        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade400,
          ),

          borderRadius:
              BorderRadius.circular(8),
        ),

        child: Text(
          selectedDurasi,

          style: const TextStyle(
            fontSize: 16,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
),

  ],
),

const SizedBox(height: 25),

                  // =====================================================
                  // TOTAL
                  // =====================================================

                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.blue.shade800,

                      borderRadius:
                          BorderRadius.circular(10),
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [

                        Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          const Text(
                            "Total Biaya Sparepart",

                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            "Rp. $totalHarga",

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
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor:
                                    Colors.white,
                              ),

                              onPressed: widget.onBack,

                              child: const Text("Batal"),
                            ),

                            const SizedBox(width: 10),

                            ElevatedButton.icon(
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor:
                                    Colors.white,
                              ),

                              onPressed: widget.onBack,

                              icon: const Icon(Icons.save),

                              label: const Text(
                                "Simpan Data Servis",
                              ),
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

  Widget sectionTitle(
    IconData icon,
    String title,
  ) {
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

        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget input(
    String hint, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: TextField(
        maxLines: maxLines,

        decoration: InputDecoration(
          hintText: hint,

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(8),
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
          DropdownMenuItem(
            value: "1",
            child: Text("Option"),
          ),
        ],

        onChanged: (v) {},

        decoration: InputDecoration(
          hintText: hint,

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}