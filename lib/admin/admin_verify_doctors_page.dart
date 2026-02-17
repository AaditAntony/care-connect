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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctors')
          .where('verificationStatus', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No pending doctor verifications",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.only(bottom: 25),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.grey.withOpacity(0.08),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ===== HEADER ROW =====
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Profile Image
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: data['profileImageBase64'] != null
                            ? MemoryImage(
                          base64Decode(data['profileImageBase64']),
                        )
                            : null,
                        child: data['profileImageBase64'] == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),

                      const SizedBox(width: 20),

                      // Doctor Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? "Doctor",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['specialization'] ?? "",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Qualification: ${data['qualification'] ?? ""}",
                              style: const TextStyle(color: Colors.black45),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Experience: ${data['experience'] ?? ""} years",
                              style: const TextStyle(color: Colors.black45),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ===== CERTIFICATE SECTION =====
                  const Text(
                    "Certificate / Proof",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (data['certificateBase64'] != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(data['certificateBase64']),
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                  const SizedBox(height: 25),

                  // ===== ACTION BUTTONS =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => rejectDoctor(doc.id),
                        child: const Text("Reject"),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => approveDoctor(doc.id),
                        child: const Text("Approve"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

}

