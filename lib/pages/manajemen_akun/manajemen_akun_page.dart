import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tambah_manajemen_akun_page.dart';

class ManajemenAkunPage extends StatefulWidget {
  const ManajemenAkunPage({super.key});

  @override
  State<ManajemenAkunPage> createState() =>
      _ManajemenAkunPageState();
}

class _ManajemenAkunPageState
    extends State<ManajemenAkunPage> {

  final TextEditingController searchController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // ================= TITLE =================

          const Text(
            "Manajemen Akun",

            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            "Kelola informasi akun admin bengkel",

            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 25),

          // ================= SEARCH + BUTTON =================

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [

              SizedBox(
                width: 300,

                child: TextField(
                  controller: searchController,

                  decoration: InputDecoration(
                    hintText: "Cari akun admin...",

                    prefixIcon:
                        const Icon(Icons.search),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(8),

                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),

                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(8),

                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),

                onPressed: () {

                  showDialog(
                    context: context,

                    builder: (context) =>
                        const TambahManajemenAkunPage(),
                  );
                },

                icon: const Icon(Icons.add),

                label: const Text(
                  "Tambah Akun",
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // ================= TABLE =================

          Container(
            padding:
                const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(8),

              border: Border.all(
                color: Colors.grey.shade400,
              ),
            ),

            child: LayoutBuilder(
              builder:
                  (context, constraints) {

                return SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal,

                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth:
                          constraints.maxWidth,
                    ),

                    child: StreamBuilder(

                      stream: FirebaseFirestore
                          .instance
                          .collection(
                              'manajemen_akun')
                          .snapshots(),

                      builder:
                          (context, snapshot) {

                        if (!snapshot.hasData) {

                          return const Center(
                            child:
                                CircularProgressIndicator(),
                          );
                        }

                        final akunList =
                            snapshot.data!.docs;

                        return DataTable(

                          border: TableBorder.all(
                            color:
                                Colors.grey.shade400,
                          ),

                          columnSpacing: 25,
                          headingRowHeight: 45,
                          dataRowMinHeight: 45,
                          dataRowMaxHeight: 55,

                          headingRowColor:
                              WidgetStateProperty.all(
                            Colors.grey.shade300,
                          ),

                          headingTextStyle:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 12,
                          ),

                          columns: const [

                            DataColumn(
                              label: Text("NO"),
                            ),

                            DataColumn(
                              label: Text("NAMA"),
                            ),

                            DataColumn(
                              label: Text("EMAIL"),
                            ),

                            DataColumn(
                              label: Text("ROLE"),
                            ),

                            DataColumn(
                              label: Text(
                                "TANGGAL DIBUAT",
                              ),
                            ),

                            DataColumn(
                              label: Text("AKSI"),
                            ),
                          ],

                          rows: List.generate(
                            akunList.length,

                            (index) {

                              final data =
                                  akunList[index];

                              return DataRow(
                                cells: [

                                  DataCell(
                                    Text(
                                      "${index + 1}",
                                    ),
                                  ),

                                  DataCell(
                                    Text(
                                      data['nama'] ??
                                          "",
                                    ),
                                  ),

                                  DataCell(
                                    Text(
                                      data['email'] ??
                                          "",
                                    ),
                                  ),

                                  const DataCell(
                                    Text("Admin"),
                                  ),

                                  DataCell(
                                    Text(

                                      data[
                                                  'created_at'] !=
                                              null

                                          ? "${data['created_at'].toDate().day}-${data['created_at'].toDate().month}-${data['created_at'].toDate().year}"

                                          : "-",
                                    ),
                                  ),

                                  // ================= AKSI =================

                                  DataCell(

                                    Row(
                                      children: [

                                        // 🔑 RESET PASSWORD

                                        GestureDetector(
                                          onTap: () {},

                                          child: Container(
                                            padding:
                                                const EdgeInsets
                                                    .all(4),

                                            decoration:
                                                BoxDecoration(
                                              color: Colors
                                                  .blue
                                                  .shade100,

                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                4,
                                              ),
                                            ),

                                            child:
                                                const Icon(
                                              Icons.key,
                                              size: 16,
                                              color:
                                                  Colors.blue,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                            width: 8),

                                        // 🗑 DELETE

                                        GestureDetector(

                                          onTap:
                                              () async {

                                            await FirebaseFirestore
                                                .instance
                                                .collection(
                                                    'manajemen_akun')
                                                .doc(
                                                    data.id)
                                                .delete();
                                          },

                                          child: Container(
                                            padding:
                                                const EdgeInsets
                                                    .all(4),

                                            decoration:
                                                BoxDecoration(
                                              color: Colors
                                                  .red
                                                  .shade100,

                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                4,
                                              ),
                                            ),

                                            child:
                                                const Icon(
                                              Icons.delete,
                                              size: 16,
                                              color:
                                                  Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}