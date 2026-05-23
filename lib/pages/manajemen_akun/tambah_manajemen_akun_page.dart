import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TambahManajemenAkunPage
    extends StatefulWidget {

  const TambahManajemenAkunPage({
    super.key,
  });

  @override
  State<TambahManajemenAkunPage>
      createState() =>
          _TambahManajemenAkunPageState();
}

class _TambahManajemenAkunPageState
    extends State<
        TambahManajemenAkunPage> {

  // ================= CONTROLLER =================

  final TextEditingController
      namaController =
      TextEditingController();

  final TextEditingController
      emailController =
      TextEditingController();

  final TextEditingController
      passwordController =
      TextEditingController();

  final TextEditingController
      konfirmasiPasswordController =
      TextEditingController();

  bool isLoading = false;

  // ================= SIMPAN DATA =================

  Future<void> simpanData() async {

    // VALIDASI PASSWORD

    if (passwordController.text !=
        konfirmasiPasswordController
            .text) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Konfirmasi password tidak sama",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      // ================= AUTH =================

      final credential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(

        email:
            emailController.text,

        password:
            passwordController.text,
      );

      // ================= FIRESTORE =================

      await FirebaseFirestore.instance
          .collection(
              'manajemen_akun')
          .doc(credential.user!.uid)
          .set({

        'uid':
            credential.user!.uid,

        'nama':
            namaController.text,

        'email':
            emailController.text,

        'password':
            passwordController.text,

        'created_at':
            Timestamp.now(),
      });

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Akun berhasil ditambahkan",
          ),
        ),
      );

    } on FirebaseAuthException catch (e) {

      String message =
          "Terjadi kesalahan";

      if (e.code ==
          'email-already-in-use') {

        message =
            "Email sudah digunakan";
      }

      else if (e.code ==
          'weak-password') {

        message =
            "Password terlalu lemah";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(message),
        ),
      );

    } catch (e) {

      debugPrint(
        "ERROR TAMBAH AKUN: $e",
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            "Error: $e",
          ),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(

      title: const Text(
        "Tambah Akun",
      ),

      content: SizedBox(
        width: 400,

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [

            // ================= NAMA =================

            TextField(
              controller:
                  namaController,

              decoration:
                  InputDecoration(
                hintText: "Nama",

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ================= EMAIL =================

            TextField(
              controller:
                  emailController,

              decoration:
                  InputDecoration(
                hintText: "Email",

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ================= PASSWORD =================

            TextField(
              controller:
                  passwordController,

              obscureText: true,

              decoration:
                  InputDecoration(
                hintText: "Password",

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ================= KONFIRM PASSWORD =================

            TextField(
              controller:
                  konfirmasiPasswordController,

              obscureText: true,

              decoration:
                  InputDecoration(
                hintText:
                    "Konfirmasi Password",

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      actions: [

        Padding(
          padding:
              const EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: 15,
          ),

          child: Row(
            children: [

              // ================= BATAL =================

              Expanded(
                child: SizedBox(
                  height: 45,

                  child:
                      ElevatedButton(

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.redAccent,

                      foregroundColor:
                          Colors.white,

                      elevation: 2,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          30,
                        ),
                      ),
                    ),

                    onPressed: () {
                      Navigator.pop(
                          context);
                    },

                    child: const Text(
                      "Batal",

                      style: TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 15),

              // ================= SIMPAN =================

              Expanded(
                child: SizedBox(
                  height: 45,

                  child:
                      ElevatedButton.icon(

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.blue,

                      foregroundColor:
                          Colors.white,

                      elevation: 2,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          30,
                        ),
                      ),
                    ),

                    onPressed: isLoading
                        ? null
                        : simpanData,

                    icon: isLoading

                        ? const SizedBox(
                            width: 18,
                            height: 18,

                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                              color: Colors
                                  .white,
                            ),
                          )

                        : const Icon(
                            Icons.save,
                            size: 18,
                          ),

                    label: Text(
                      isLoading
                          ? "Loading..."
                          : "Simpan",

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}