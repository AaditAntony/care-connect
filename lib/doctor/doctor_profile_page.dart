import 'dart:convert';

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
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
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

          final data =
              snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text("Profile not found"));
          }

          final isVerified = data['isVerified'] ?? false;
          final verificationStatus =
              data['verificationStatus'] ?? "pending";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                /// 🔵 Profile Image + Name
                if (data['profileImageBase64'] != null)
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: MemoryImage(
                      base64Decode(data['profileImageBase64']),
                    ),
                  )
                else
                  const CircleAvatar(
                    radius: 55,
                    child: Icon(Icons.person, size: 50),
                  ),

                const SizedBox(height: 15),

                Text(
                  data['name'] ?? "Doctor",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  data['email'] ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 15),

                /// Verification Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isVerified
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isVerified
                        ? "Verified Doctor"
                        : "Status: $verificationStatus",
                    style: TextStyle(
                      color: isVerified
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔵 Professional Details Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        buildDetailRow(
                            "Qualification",
                            data['qualification'] ?? ""),

                        buildDetailRow(
                            "Specialization",
                            data['specialization'] ?? ""),

                        buildDetailRow(
                            "Experience",
                            "${data['experience'] ?? ""} years"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// 🔵 Certificate Preview
                if (data['certificateBase64'] != null)
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Certificate",
                        style: TextStyle(
                            fontWeight:
                                FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Image.memory(
                        base64Decode(
                            data['certificateBase64']),
                        height: 150,
                      ),
                    ],
                  ),

                const SizedBox(height: 25),

                /// 🔵 Signature Preview
                if (data['signatureBase64'] != null)
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Signature",
                        style: TextStyle(
                            fontWeight:
                                FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Image.memory(
                        base64Decode(
                            data['signatureBase64']),
                        height: 80,
                      ),
                    ],
                  ),

                const SizedBox(height: 40),

                /// 🔴 Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => logout(context),
                    child: const Text("Logout"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}