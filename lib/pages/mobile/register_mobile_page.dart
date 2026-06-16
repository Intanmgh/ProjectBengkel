import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterMobilePage extends StatefulWidget {
  const RegisterMobilePage({super.key});

  @override
  State<RegisterMobilePage> createState() => _RegisterMobilePageState();
}

class _RegisterMobilePageState extends State<RegisterMobilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> registerUser() async {
    // 1. Validasi Input Kosong
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Kata Sandi tidak boleh kosong!")),
      );
      return;
    }

    // 2. Validasi Kesamaan Kata Sandi (Tambahan Baru)
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kata Sandi dan Konfirmasi Kata Sandi tidak cocok!"), 
          backgroundColor: Colors.orange
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 3. Daftarkan akun ke Auth pusat proyek
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 4. Ambil UID yang baru saja terbuat
      String uid = userCredential.user!.uid;

      // 5. Buat koleksi 'users' di Cloud Firestore secara otomatis untuk mengunci role pelanggan
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': emailController.text.trim(),
        'role': 'pelanggan', // Pengenal utama akun mobile pelanggan otomatis terproteksi
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Register pelanggan berhasil!"), backgroundColor: Colors.green),
      );

      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Register gagal: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 10.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Halaman
                      const Text(
                        "Daftar Akun Baru",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Silahkan lengkapi data untuk membuat akun mobile",
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      
                      const Spacer(),

                      // ALAMAT EMAIL
                      const Text("Alamat Email", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "nama@email.com",
                          prefixIcon: const Icon(Icons.email, size: 20),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // KATA SANDI
                      const Text("Kata Sandi", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock, size: 20),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // KONFIRMASI KATA SANDI
                      const Text("Konfirmasi Kata Sandi", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_clock_outlined, size: 20),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // TOMBOL DAFTAR
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: isLoading ? null : registerUser,
                          child: isLoading 
                              ? const SizedBox(
                                  width: 18, 
                                  height: 18, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Text("Daftar Sekarang", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}