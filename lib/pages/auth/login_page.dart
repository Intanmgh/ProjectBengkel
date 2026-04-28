import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart';
import '../dashboard/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) return; // 🔥 FIX WAJIB

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );

  } catch (e) {
    if (!mounted) return; // 🔥 FIX WAJIB

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login gagal: $e")),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [

          // 🔵 LEFT
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', width: 200),
                  const SizedBox(height: 20),
                  const Text(
                    "JIMU MITSUBISHI",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Sistem Manajemen Bengkel untuk Pelayanan Terbaik",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // ⚪ RIGHT
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Selamat Datang",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text("Silahkan masuk untuk mengelola dashboard admin"),
                      const SizedBox(height: 30),

                      // EMAIL
                      const Text("Alamat Email"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "nama@email.com",
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // PASSWORD
                      const Text("Kata Sandi"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔥 BUTTON LOGIN (SUDAH CONNECT FIREBASE)
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: loginUser,
                          child: const Text("Masuk"),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // REGISTER
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text("Belum punya akun? Daftar disini"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}