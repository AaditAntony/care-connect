import 'package:flutter/material.dart';
import 'admin_verify_doctors_page.dart';

class AdminEntryPage extends StatelessWidget {
  const AdminEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width
    final double screenWidth = MediaQuery.of(context).size.width;

    // 🔐 Admin allowed only on large screens
    if (screenWidth >= 600) {
      return const AdminVerifyDoctorsPage();
    }

    // ❌ Admin NOT allowed on mobile
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Access"),
        centerTitle: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "Admin panel is not supported on mobile devices.\n\n"
                "Please access this page using a desktop or laptop.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
