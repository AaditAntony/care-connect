import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminVerifyDoctorsPage extends StatelessWidget {
  const AdminVerifyDoctorsPage({super.key});

  /// Approve doctor
  Future<void> approveDoctor(String doctorId) async {
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .update({
      'verificationStatus': 'approved',
      'isVerified': true,
    });
  }

  /// Reject doctor
  Future<void> rejectDoctor(String doctorId) async {
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .update({
      'verificationStatus': 'rejected',
      'isVerified': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin – Doctor Verification"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .where('verificationStatus', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // No pending doctors
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No pending doctor verifications"),
            );
          }

          // Doctor list
          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor basic details
                      Text(
                        data['name'] ?? "Doctor",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text("Qualification: ${data['qualification']}"),
                      Text("Specialization: ${data['specialization']}"),
                      Text("Experience: ${data['experience']} years"),

                      const SizedBox(height: 15),

                      // Profile image
                      const Text(
                        "Profile Image",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (data['profileImageBase64'] != null)
                        Image.memory(
                          base64Decode(data['profileImageBase64']),
                          height: 120,
                        ),

                      const SizedBox(height: 15),

                      // Certificate image
                      const Text(
                        "Certificate / Proof",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (data['certificateBase64'] != null)
                        Image.memory(
                          base64Decode(data['certificateBase64']),
                          height: 180,
                        ),

                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => rejectDoctor(doc.id),
                            child: const Text("Reject"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () => approveDoctor(doc.id),
                            child: const Text("Approve"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

