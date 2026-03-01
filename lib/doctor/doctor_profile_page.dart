import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login.dart';

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("My Profile", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('doctors')
            .doc(doctorId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text("Profile not found"));
          }

          final isVerified = data['isVerified'] ?? false;
          final verificationStatus = data['verificationStatus'] ?? "pending";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// 🔵 Profile Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      /// Profile Image
                      if (data['profileImageBase64'] != null)
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: MemoryImage(
                            base64Decode(data['profileImageBase64']),
                          ),
                        )
                      else
                        const CircleAvatar(
                          radius: 60,
                          backgroundColor: Color(0xFF00897B),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),

                      const SizedBox(height: 16),

                      /// Name
                      Text(
                        data['name'] ?? "Doctor",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// Email
                      Text(
                        data['email'] ?? "",
                        style: const TextStyle(color: Colors.black54),
                      ),

                      const SizedBox(height: 16),

                      /// Verification Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? Colors.green.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          isVerified
                              ? "Verified Doctor"
                              : "Status: $verificationStatus",
                          style: TextStyle(
                            color: isVerified ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔵 Professional Details Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Professional Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      buildDetailTile(
                        Icons.school,
                        "Qualification",
                        data['qualification'] ?? "",
                      ),
                      buildDetailTile(
                        Icons.medical_services,
                        "Specialization",
                        data['specialization'] ?? "",
                      ),
                      buildDetailTile(
                        Icons.workspace_premium,
                        "Experience",
                        "${data['experience'] ?? ""} years",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔵 Certificate Section
                if (data['certificateBase64'] != null)
                  buildImageSection(
                    title: "Certificate",
                    image: base64Decode(data['certificateBase64']),
                    height: 170,
                  ),

                const SizedBox(height: 20),

                /// 🔵 Signature Section
                if (data['signatureBase64'] != null)
                  buildImageSection(
                    title: "Signature",
                    image: base64Decode(data['signatureBase64']),
                    height: 90,
                  ),

                const SizedBox(height: 40),

                /// 🔴 Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => logout(context),
                    child: const Text(
                      "Logout",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildDetailTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00897B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImageSection({
    required String title,
    required Uint8List image,
    required double height,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
            ],
          ),
          child: Image.memory(image, height: height, fit: BoxFit.contain),
        ),
      ],
    );
  }
}
