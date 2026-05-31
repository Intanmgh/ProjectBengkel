import 'package:flutter/material.dart';

class ServisMobilePage extends StatelessWidget {
  const ServisMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Status Servis",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: const SafeArea(
        child: Center(
          child: Text(
            "Halaman Servis Kosong",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}